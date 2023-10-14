# Configure the backend to backup the tf state file
terraform {
  backend "s3" {
    bucket = "terraform-state-mamatha"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt = true
    
  }

}