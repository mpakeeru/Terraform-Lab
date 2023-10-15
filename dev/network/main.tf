provider "aws" {
    region = var.aws_region
 #   profile = "myaws"
}

# Configure the backend to backup the tf state file
terraform {
  backend "s3" {
    bucket = "terraform-state-mamatha"
    key = "dev/network/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt = true
 #   profile = "myaws"
  }

}