# simple-webserver

This web server will be deployed using IaC Terraform 
It will be running on an Ec2 instance in a Private subnet
it will be placed behind an application loadbalancer that is public facing
There will be an autoscaling with the below scaling policy

-scale-in when the CPU utilization > 80%
-Scale-out when the CPU utilization is < 60%
-The minimum number of instance should be 1 while maximum is 3

Install a webserver (Apache, NGINX, etc) through bootstrapping
The webserver should be accessible only through the load balancer










