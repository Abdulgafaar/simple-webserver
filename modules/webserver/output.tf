output "public-dns-name" {
  value = aws_lb.webserver-ELB.dns_name
}

output "alb-id" {
  value = aws_lb.webserver-ELB.dns_name
}

output "webserver" {
  value = aws_instance.webserver-instance.id
}

