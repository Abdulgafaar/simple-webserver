output "public-dns-name" {
  value = aws_lb.webserver-ELB.dns_name
}

output "alb-id" {
  value = aws_lb.webserver-ELB.dns_name
}

output "aws_ami" {
  value = data.aws_ami.webserver-ami.image_id
}

