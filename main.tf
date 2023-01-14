module "VPC" {
  source              = "app.terraform.io/GreenSpot/VPC/GreenSport"
   version = "1.0.0"
  public-subnets      = local.public-subnets
  private-subnets     = local.private-subnets
  resource-identifier = var.resource-identifier
  az-count            = local.az-count
  tags                = local.tags
}

module "webserver" {
  source              = "app.terraform.io/GreenSpot/webserver/GreenSport"
  version = "1.0.0"
  resource-identifier = var.resource-identifier
  vpc                 = module.vpc.vpc-id
  public-subnets      = module.vpc.public-subnets
  private-subnets     = module.vpc.private-subnets
  az-count            = local.az-count
  aws_ami             = module.webserver.aws_ami

}