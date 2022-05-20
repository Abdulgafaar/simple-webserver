**Step-1** 
simple-webserver
To run the deployment script 

**Step-2**
Set the backend configuration
I used S3 for backend state and Dynamodb for the stateLock so this can be commented out and set to local or a new backend state
Also a keypair needs to be generated and place the public on the keypair resources block.
./module/webserver/webserver.tf 
Change the public key on line 4
Ensure to be at the root of the project then follow the steps below

**Step-3**
Initialize Terraform
-- terraform init

**Step-4**
Run a plan to see the resources to be provisioned

-- terraform plan

**Step-5**
Deploy the resources by running below command

-- terraform deploy












