# terraform {
#   backend "s3" {
#     bucket         = "abdul-terraform-backend-state"
#     key            = "terraform.tfstate"
#     region         = "eu-west-1"
#     dynamodb_table = "terraform-statetable"
#   }
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 3.0"
#     }
#   }
# }

terraform {
  backend "remote" {
    organization = "GreenSpot"

    workspaces {
      name = "simple-webserver"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74.2"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = local.region
  allowed_account_ids = [local.aws_account_id]

  assume_role {
    role_arn = "arn:aws:iam::${local.aws_account_id}:role/terraform-admin-role"
  }

}

locals {
  aws_account_id = "964165057512"
  region        = "eu-west-1"
}