provider "aws" {
    region = "us-east-2"

}

data "terraform_remote_state" "network" {
    backend = "s3"
    config = {
      bucket = "${var.network_remote_state_bucket}"
      key = "${var.network_remote_state_key}"
      region = "us-east-2"
    
    }

}


#create appserver instances
resource "aws_instance" "instance" {
  ami = var.ubuntu_ami
  instance_type = var.instance_type
  key_name = var.key_pair
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_2a
  vpc_security_group_ids = [aws_security_group.SG-appserver.id]
tags = {
  Name = "${var.app_name}-appserver"
  Environment = var.tag_environment
}
}

#create security group
resource "aws_security_group" "SG-appserver" {
  name = "${var.app_name}-SG"
  vpc_id = data.terraform_remote_state.network.outputs.vpc-id


    #Incoming traffic
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   #Outgoing traffic
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
      Name = "${var.app_name}-SG"
      Environment = var.tag_environment
      
    }
}