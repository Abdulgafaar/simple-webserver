# simple-webserver
To run the deployment script 

# Set the backend configuration
I used S3 for backend state and Dynamodb for the stateLock so this can be commented out and set to local or a nuw backend state

# Initialize the Terraform
-- terraform init

# Run a plan to see the resources to be provisioned

-- terraform plan

# deploy the resources by running below command

-- terraform deploy

This web server will be deployed using IaC Terraform 
It will be running on an Ec2 instance in a Private subnet
it will be placed behind an application loadbalancer that is public facing
There will be an autoscaling with the below scaling policy

-scale-in when the CPU utilization > 80%
-Scale-out when the CPU utilization is < 60%
-The minimum number of instance should be 1 while maximum is 3

Install a webserver (Apache, NGINX, etc) through bootstrapping
The webserver should be accessible only through the load balancer










