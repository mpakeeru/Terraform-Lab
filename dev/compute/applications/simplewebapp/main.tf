provider "aws" {
    region = "us-east-2"
    # profile = "myaws"
}

# Configure the backend to backup the tf state file
terraform {
  backend "s3" {
    bucket = "terraform-state-mamatha"
    key = "dev/compute/applications/simplewebapp/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt = true
    # profile = "myaws"
  }

}
data "terraform_remote_state" "network" {
    backend = "s3"
    config = {
      bucket = "terraform-state-mamatha"
      key = "dev/network/s3/terraform.tfstate"
      region = "us-east-2"
      # profile = "myaws"
    }

}


#create appserver instances
resource "aws_instance" "simplewebapp-appserver" {
  ami = var.ubuntu-ami
  instance_type = "t2.micro"
  key_name = "mamatha-aws-keypair"
 # key_name = aws_key_pair.test-key.key_name
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_2a
  vpc_security_group_ids = [aws_security_group.SG-appserver.id]
   user_data = <<EOF
#!/bin/bash
sudo su -
apt update
apt upgrade -y
apt install openjdk-11-jdk -y
apt install tomcat9 tomcat9-admin tomcat9-docs tomcat9-common git -y
apt-get install jq ruby-full ruby-webrick wget -y
wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl start codedeploy-agent
systemctl enable codedeploy-agent
systemctl start tomcat9
systemctl enable tomcat9
  EOF
tags = {
  Name = "simplewebapp-appserver"
  Environment = "${var.environment}"
}
}

#create security group
resource "aws_security_group" "SG-appserver" {
  name = "SG-appserver"
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
      Name = "SG-appserver"
      Environment = "${var.environment}"
      
    }
}
