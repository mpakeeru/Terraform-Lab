#creating S3bucket
resource "aws_s3_bucket" "vprofile-s3bucket" {
    bucket = "vprofile-s3bucket"
    force_destroy = true  
}
resource "aws_s3_bucket_versioning" "vprofile-s3bucket"{
    bucket = aws_s3_bucket.vprofile-s3bucket.id
    versioning_configuration {
      status = "Enabled"
    }
  
}
