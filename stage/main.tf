provider "aws" {
    region = "us-east-2"
  
}

# Configure the backend to backup the tf state file
terraform {
  backend "s3" {
    bucket = "terraform-state-mamatha"
    key = "stage/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt = true
   
  }
}

  module "app-server" {
    source = "../modules/ec2"
    ubuntu_ami = "ami-024e6efaf93d85776"
    instance_type = "t2.micro"
    key_pair = "mamatha-aws-keypair"
    tag_environment = "staging"
    app_name = "test-app"
    network_remote_state_bucket= "${var.network_remote_state_bucket}"
    network_remote_state_key = "${var.network_remote_state_key}"
    tag_name = "test"
  }