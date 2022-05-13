resource "aws_vpc" "vpc" {
  enable_dns_hostnames = true
  enable_dns_support   = true
  cidr_block           = var.vpc-cidr
  tags = marge(local.tags, {
    Name = var.resource-identifier
  })
}

resource "aws_subnet" "public-subnet" {
  for_each                = toset(var.public-subnets)
  cidr_block              = each.key
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone = element(
    local.azs,
    index(var.public-subnets, each.key)
  )

  tags = merge(local.tags, {
    Name = format("%s-public-%s",
      var.resource-identifier,
      index(var.public-subnets, each.key)
    )
  })
}

resource "aws_internet_gateway" "internet-GW" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags, {
    Name = var.resource-identifier
  })

}

resource "aws_route_table" "public-RTB" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags, {
    Name = var.resource-identifier
  })
}

resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.public-RTB
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-GW.id

  timeouts {
    create = "4m"
  }
}

resource "aws_route_table_association" "public-RTB-association" {
  for_each       = aws_subnet.public-subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public-RTB.id
}

resource "aws_eip" "nat-eip" {
  for_each = toset(local.nat_azs)
  vpc      = true

  tags = merge(local.tags, {
    Name = format("%s-%s", var.resource-identifier, each.key)
  })
}

resource "aws_nat_gateway" "nat-GW" {
  for_each      = aws_eip.nat-eip
  allocation_id = each.value.id
  subnet_id = element(local.public-subnet-ids,
    index(keys(aws_eip.nat-eip), each.key)
  )
  tags = merge(local.tags, {
    Name = format("%s-%s", var.resource-identifier, each.key)
  })

  depends_on = [
    aws_internet_gateway.internet-GW
  ]
}

resource "aws_subnet" "private-subnet" {
  for_each          = toset(var.private-subnets)
  cidr_block        = each.key
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(local.azs, index(var.private-subnets, each.key))

  tags = merge(local.tags, {

    Name = format("%s-private-%s", var.resource-identifier, index(var.private-subnets, each.key))
  })
}

resource "aws_route_table" "private-RTB" {
  for_each = toset(local.azs)
  vpc_id   = aws_vpc.vpc.id

  tags = merge(local.tags, {
    Name = format("%s-private-%s", var.resource-identifier, each.key)
  })
}

resource "aws_route" "private-route" {
  for_each               = toset(local.azs)
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private-RTB[each.key].id
  nat_gateway_id         = aws_nat_gateway.nat-GW[each.key].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private-RTB-association" {
  for_each  = aws_subnet.private-subnet
  subnet_id = each.value.id
  route_table_id = element(local.private-route-table-ids,
    index(keys(aws_subnet.private-subnet), each.key)
  )
}

