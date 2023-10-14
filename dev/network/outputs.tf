output "vpc-id" {
    description = "dev-vpc id "
    value = aws_vpc.dev-vpc.id
  
}
output "public_subnet_2a" {
    description = "public-subnet-2a.id "
    value = aws_subnet.public_subnet_2a.id
  
}
output "public_subnet_2b" {
    description = "public-subnet-2b.id "
    value = aws_subnet.public_subnet_2b.id
  
}
output "private_subnet_2a" {
    description = "private-subnet-2a.id "
    value = aws_subnet.private_subnet_2a.id
  
}
output "private_subnet_2b" {
    description = "private-subnet-2b.id "
    value = aws_subnet.private_subnet_2b.id
  
}