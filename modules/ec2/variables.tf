# Input variable: network remote state bucket name
variable "network_remote_state_bucket" {
  description = "The name of the S3 bucket for the networks's remote state"
}

# Input variable: network remote state bucket key
variable "network_remote_state_key" {
  description = "The path for networks's remote state in S3"
}

# Input variable: ubuntu ami ID
variable "ubuntu_ami" {
  description = "AMI ID for Ubuntu"
}

# Input variable: Instance_type
variable "instance_type" {
  description = "instance tpe"
}

# Input variable: Key Pair
variable "key_pair" {
  description = "key pair name"
}

# Input variable: Tag-Name
variable "tag_name" {
  description = "Name Tag"
}

# Input variable: Environment
variable "tag_environment" {
  description = "environment tag"
}

# Input variable: app name
variable "app_name" {
  description = "app_name name"
}