locals {
  tags = merge(var.tags, {
    created_by = "terraform"
  })

  azs = slice(data.aws_availability_zones.azs.name,
    0,
    var.az-count
  )
  nat_gateway_count = var.nat-gateway ? 1 : var.az-count
  nat_azs           = slice(local.azs,0 ,local.nat_gateway_count )

  public-subnet-ids = [for key, public_subnet in aws_subnet.public-subnet : public_subnet.id]
  private-route-table-ids = [for key, route_table in aws_route_table.private-RTB : public_subnet.id]
}