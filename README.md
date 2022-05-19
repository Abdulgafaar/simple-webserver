# simple-webserver
To run the deployment script 

# Set the backend configuration
I used S3 for backend state and Dynamodb for the stateLock so this can be commented out and set to local or a nuw backend state
Also a keypair needs to generated and place the public on the keypair resources block.

ensure to be at the root of the project then follow the steps below
# Initialize the Terraform
-- terraform init

# Run a plan to see the resources to be provisioned

-- terraform plan

# deploy the resources by running below command

-- terraform deploy












