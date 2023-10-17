# Input variable: Networkremote state bucket name
variable "network_remote_state_bucket" {
  description = "The name of the S3 bucket for the network remote state"
  default     =  "terraform-state-mamatha"
}

# Input variable: network remote state bucket key
variable "network_remote_state_key" {
  description = "The path for network remote state in S3"
  default     = "dev/network/s3/terraform.tfstate"
}

