module "vpc" {
  source = "./modules/vpc"
  vpc-cidr             = local.vpc-cidr-block
  public-subnets       = local.public-subnets
  private-subnets      = local.private-subnets
  resource-identifier  = var.resource-identifier
  az-count             = local.az-count
  tags                 = local.tags
}

module "webserver" {
  source              = "./modules/webserver"
  resource-identifier = var.resource-identifier
  vpc                 = module.vpc.vpc-id
  public-subnets      = module.vpc.public-subnets
  private-subnets     = module.vpc.private-subnets
  az-count            = local.az-count

}