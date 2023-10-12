

#create appserver instances
resource "aws_instance" "vprofile-appserver" {
  ami = var.ubuntu-ami
  instance_type = "t2.micro"
  key_name = "mamatha-aws-keypair"
 # key_name = aws_key_pair.test-key.key_name
  subnet_id = aws_subnet.public_subnet_2a.id
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
  Name = "vprofile-appserver"
  Environment = "${var.environment}"
}
}

#create security group
resource "aws_security_group" "SG-appserver" {
  name = "SG-appserver"
  vpc_id = aws_vpc.main.id

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
  #create security group for backend 
  resource "aws_security_group" "SG-backend" {
    name = "SG-backend"
    vpc_id = aws_vpc.main.id
    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = ["${aws_security_group.SG-appserver.id}"]
    }
    ingress {
      from_port = 11211
      to_port = 11211
      protocol = "tcp"
      security_groups = ["${aws_security_group.SG-appserver.id}"]

    }
    ingress {
      from_port = 5672
      to_port = 5672
      protocol = "tcp"
      security_groups = ["${aws_security_group.SG-appserver.id}"]
    }
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      security_groups = ["${aws_security_group.SG-appserver.id}"]
    }
    
      ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "SG-backend"
      Environment = "${var.environment}"
      
    }
  }
#create LoadBalancer
resource "aws_security_group" "SG-elb" {
  name = "SG-elb"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
    }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "SG-elb"
      Environment = "${var.environment}"
    }
  }
  
#creating memecache server
resource "aws_instance" "vprofile-memecache" {
   ami = var.centos-ami
  instance_type = "t2.micro"
  key_name = "mamatha-aws-keypair"
  #key_name = aws_key_pair.test-key.key_name
  subnet_id = aws_subnet.private_subnet_2a.id
  vpc_security_group_ids = [aws_security_group.SG-backend.id]
  depends_on = [ aws_nat_gateway.nat_gateway-terraformdev ]
   user_data = <<EOF
#!/bin/bash
sudo su -
dnf install epel-release -y
dnf install memcached -y
systemctl start memcached
systemctl enable memcached
systemctl status memcached
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
systemctl restart memcached
firewall-cmd --add-port=11211/tcp
firewall-cmd --runtime-to-permanent
firewall-cmd --add-port=11111/udp
firewall-cmd --runtime-to-permanent
memcached -p 11211 -U 11111 -u memcached -d
EOF
tags = {
  Name = "vprofile-memecache"
  Environment = "${var.environment}"
}
 
}

#creating DB server
resource "aws_instance" "vprofile-dbserver" {
 ami = var.centos-ami
  instance_type = "t2.micro"
  key_name = "mamatha-aws-keypair"
  #key_name = aws_key_pair.test-key.key_name
  subnet_id = aws_subnet.private_subnet_2a.id
  vpc_security_group_ids = [aws_security_group.SG-backend.id]
  depends_on = [ aws_nat_gateway.nat_gateway-terraformdev ]
  user_data = <<EOF
#!/bin/bash
sudo su -
DATABASE_PASS='admin123'
yum update -y
yum install epel-release -y
yum install git zip unzip -y
yum install mariadb-server -y
# starting & enabling mariadb-server
systemctl start mariadb
systemctl enable mariadb
cd /tmp/
git clone -b main https://github.com/hkhcoder/vprofile-project.git
#restore the dump file for the application
mysqladmin -u root password "$DATABASE_PASS"
mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"
mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Restart mariadb-server
systemctl restart mariadb


#starting the firewall and allowing the mariadb to access from port no. 3306
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --get-active-zones
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload
systemctl restart mariadb
EOF
tags = {
  Name = "vprofile-dbserver"
  Environment = "${var.environment}"
}
}

#creating rabitt MQ server
resource "aws_instance" "vprofile-mqserver" {
 ami = var.centos-ami
  instance_type = "t2.micro"
  key_name = "mamatha-aws-keypair"
  #key_name = aws_key_pair.test-key.key_name
  subnet_id = aws_subnet.private_subnet_2a.id
  vpc_security_group_ids = [aws_security_group.SG-backend.id]
  depends_on = [ aws_nat_gateway.nat_gateway-terraformdev ]
  user_data = <<EOF
#!/bin/bash
sudo su -
install epel-release -y
yum update -y
yum install wget -y
cd /tmp/
dnf -y install centos-release-rabbitmq-38
dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
systemctl enable --now rabbitmq-server
firewall-cmd --add-port=5672/tcp
firewall-cmd --runtime-to-permanent
systemctl start rabbitmq-server
systemctl enable rabbitmq-server
systemctl status rabbitmq-server
sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
rabbitmqctl add_user test test
rabbitmqctl set_user_tags test administrator
systemctl restart rabbitmq-server
EOF


tags = {
  Name = "vprofile-mqserver"
  Environment = "${var.environment}"
}
}