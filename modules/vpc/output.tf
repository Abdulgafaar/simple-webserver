output "vpc-id" {
  description = "this is to output the vpc id"
  value = aws_vpc.vpc.id
}

output "public-subnets" {
  value = aws_subnet.public-subnet
}



output "private-subnets" {
  value = aws_subnet.private-subnet
}