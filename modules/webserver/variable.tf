variable "vpc" {
  description = "The vpc id"
  type = string
  default = "default"
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
variable "counts" {
  default = 1
}

variable "public-subnets" {
  description = "This is a list of cidr assign to public subnets"
  type        = map
  default = {}
}

variable "private-subnets" {
  description = "This is a list of cidr assign to private subnets"
  type        = map
  default     = {}
}

variable "az-count" {}

variable "tags" {
  description = "the resource tags"
  type        = map(any)
  default     = {}
}

variable "aws_ami" {}