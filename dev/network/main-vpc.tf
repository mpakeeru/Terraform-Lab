#Create VPC
resource "aws_vpc" "dev-vpc" {
   cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
  
}

# creating public subnet in AZ-2a with public IP assignment
resource "aws_subnet" "public_subnet_2a" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block  = var.public_subnet_cidr_2a
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.environment}-${var.aws_region}a-public-subnet"
      Environment = var.environment
    }
}

# creating public subnet in AZ-2b with public IP assignment
resource "aws_subnet" "public_subnet_2b" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block  = var.public_subnet_cidr_2b
    availability_zone = "${var.aws_region}b"
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.environment}-${var.aws_region}b-public-subnet"
      Environment = var.environment
    }
}
# creating private subnet in AZ-2a with private IP assignment
resource "aws_subnet" "private_subnet_2a" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block  = var.private_subnet_cidr_2a
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = false
    tags = {
      Name = "${var.environment}-${var.aws_region}a-private-subnet"
      Environment = var.environment
    }
}

# creating private subnet in AZ-2b with private IP assignment
resource "aws_subnet" "private_subnet_2b" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block  = var.private_subnet_cidr_2b
    availability_zone = "${var.aws_region}b"
    map_public_ip_on_launch = false
    tags = {
      Name = "${var.environment}-${var.aws_region}b-private-subnet"
      Environment = var.environment
    }
}
#creating internet gateway
resource "aws_internet_gateway" "igw-devlopment" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name        = "${var.environment}-IGW"
    Environment = var.environment
  }
}
#creating a elastic IP for NAT 
resource "aws_eip" "nat_eip" {
    
    depends_on = [ aws_internet_gateway.igw-devlopment ]
    tags = {
    Name        = "${var.environment}-nat_eip"
    Environment = var.environment
  }
  
}
#creating NAT gateway 
resource "aws_nat_gateway" "nat_gateway-devlopment" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public_subnet_2a.id
    tags = {
      Name = "nat-gateway-${var.environment}"
      Environment = var.environment
    }


}

#creating a route table for private subnet
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.dev-vpc.id
    tags = {
      Name = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
    }
  
}

#creating a route table for public subnet
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.dev-vpc.id
    tags = {
      Name = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
    }
  
}

#add route for IGW
resource "aws_route" "public_internet_gateway" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-devlopment.id

  
}
#add route for nat gateway
resource "aws_route" "private_internet_gateway" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway-devlopment.id
  
}
#route table associations for public and private subnets
resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public_subnet_2a.id
    route_table_id = aws_route_table.public.id

  
}
resource "aws_route_table_association" "public1" {
    subnet_id = aws_subnet.public_subnet_2b.id
    route_table_id = aws_route_table.public.id
  
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private_subnet_2a.id
    route_table_id = aws_route_table.private.id
  
}
resource "aws_route_table_association" "private1" {
    subnet_id = aws_subnet.private_subnet_2b.id
    route_table_id = aws_route_table.private.id
  
}

