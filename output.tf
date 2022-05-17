output "vpc" {
  value = module.vpc.vpc-id
}

output "private-subnets" {
  value = module.vpc.private-subnets
}
output "public-subnets" {
  value = module.vpc.public-subnets
}


output "public-dns" {
  value = module.webserver.public-dns-name
}

output "alb" {
  value = module.webserver.alb-id
}

