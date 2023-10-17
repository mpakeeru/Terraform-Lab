output "instance-public-ip" {
    value = aws_instance.instance.public_ip
}
output "instance-instance-id" {
    value = aws_instance.instance.id
}