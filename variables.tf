variable "aws_region" {
    default = "us-east-2"
}

variable "environment" {
    default = "terraform-dev"
  
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_2a" {
    default = "10.0.1.0/24"
    description = "CIDR block for public subnet running in az-2a"
  
}

variable "public_subnet_cidr_2b" {
    default = "10.0.2.0/24"
    description = "CIDR block for public subnet running in az-2b"
  
}

variable "private_subnet_cidr_2a" {
    default = "10.0.3.0/24"
    description = "CIDR block for private subnet running in az-2a"
  
}

variable "private_subnet_cidr_2b" {
    default = "10.0.4.0/24"
    description = "CIDR block for private subnet running in az-2b"
  
}