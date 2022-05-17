locals {
  tags = {
    created_by = "terraform"
    environment = "dev"
  }



  az-count = 3
  vpc-cidr-block = "172.16.0.0/20"
  public-superset = cidrsubnet(local.vpc-cidr-block, 3 , 0 )
  private-superset = cidrsubnet(local.vpc-cidr-block, 3 , 1)

  public-subnets = [for index in range(local.az-count) :
          cidrsubnet(local.public-superset, 3 ,index )
  ]

  private-subnets = [for index in range(local.az-count) :
  cidrsubnet(local.private-superset, 3 ,index )
  ]
}

