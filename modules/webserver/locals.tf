
locals {
  tags = merge(var.tags, {
    created_by = "terraform"
  })

  azs = slice(data.aws_availability_zones.azs.names,
    0,
    var.az-count
  )


  public-subnets = [for key, public_subnet in var.public-subnets : public_subnet]
  private-subnets = [for key, private_subnet in var.private-subnets : private_subnet]

ami-id = data.aws_ami.webserver-ami.id
}