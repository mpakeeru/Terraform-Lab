provider "aws" {
    region = "us-eat-2"
    profile = "myaws"
}

# Configure the backend to backup the tf state file
terraform {
  backend "s3" {
    bucket = "terraform-state-mamatha"
    key = "dev/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt = true
    profile = "myaws"
  }

}
