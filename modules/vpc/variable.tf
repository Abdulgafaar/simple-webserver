variable "region" {
  description = "The region the resources will be deployed"
  default     = "eu-west-1"
}


variable "vpc-cidr" {
  description = "This is the vpc for the prod"
  type        = string
  default     = "172.30.0.0/16"

}


variable "instance-tenancy" {
  description = "This is to define if the tenancy of the VPC if it default or dedicated"
  type        = string
  default     = "default"
}

variable "resource-identifier" {
  description = "This is an identifier of the resources"
  type        = string
  default     = "default"
}

variable "public-subnets" {
  description = "This is a list of cidr assign to public subnets"
  type        = list(any)
  default = []
}

variable "private-subnets" {
  description = "This is a list of cidr assign to private subnets"
  type = list(any)
  default = []

}

variable "az-count" {
  description = "Count of the number of availability zone in the region"
  type        = number
  default     = 1
}

variable "ami-id" {
  description = "this is the image ID the ec2 instance will use"
  type        = string
  default     = "ami-0c1bc246476a5572b"
}

variable "instance-type" {
  description = "Instance type to be used"
  type        = string
  default     = "t2.micro"
}

variable "pem-key" {
  description = "The keypair use to login to the webserver"
  type        = string
  default     = "./webserver-key.pem"
}

variable "nat-gateway" {
  type = bool
  description = "A flag to indicate if single nat is true"
  default     = false
}



variable "tags" {
  description = "the resource tags"
  type        = map(any)
  default     = {}
}