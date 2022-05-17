variable "region" {
  description = "The region the resources will be deployed"
  default     = "eu-west-1"
}


variable "vpc-cidr" {
  description = "This is the vpc for the prod"
  type        = string
  default     = "172.16.0.0/20"

}

variable "resource-identifier" {
  description = "This is an identifier of the resources"
  type        = string
  default     = "default"
}
#
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