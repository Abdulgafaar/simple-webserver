module "vpc" {
  source = "./modules/vpc"
  vpc-cidr             = local.vpc-cidr-block
  public-subnets       = local.public-subnets
  private-subnets      = local.private-subnets
  resource-identifier  = var.resource-identifier
  az-count             = local.az-count
  tags                 = local.tags
}