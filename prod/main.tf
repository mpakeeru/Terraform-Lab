module "prod-appserver" {
  source = "../modules/ec2"
    ubuntu_ami = "ami-024e6efaf93d85776"
    instance_type = "t2.micro"
    key_pair = "mamatha-aws-keypair"
    tag_environment = "prod"
    app_name = "prod-app"
    network_remote_state_bucket= "${var.network_remote_state_bucket}"
    network_remote_state_key = "${var.network_remote_state_key}"
    tag_name = "prod"
  }

