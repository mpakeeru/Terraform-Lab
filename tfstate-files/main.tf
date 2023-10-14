provider "aws" {
    region = "us-east-2"
    profile = "myaws" 
}
# Create S3 bucket to store state files
resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-state-mamatha"
    # Prevent accidental deletion of this S3 bucket
    lifecycle {
      prevent_destroy = true
    }
  
}

# Enable versioning on S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state_version" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status = "Enabled"
    }
  
}

# configure aws s3 server side encryption 
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
    bucket = aws_s3_bucket.terraform_state.id
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }


}
# Block the public access to  the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
  
}
# Creating DynamoDB 
resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
      name = "LockID"
      type = "S"

    }
  
}
