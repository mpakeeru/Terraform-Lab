output "simplewebapp-appserver-public-ip" {
    value = aws_instance.simplewebapp-appserver.public_ip
}
output "simplewebapp-appserver-instance-id" {
    value = aws_instance.simplewebapp-appserver.id
}