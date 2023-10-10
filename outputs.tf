

output "AppserverPublicIP" {
    description = "public ip address "
    value = aws_instance.vprofile-appserver.public_ip
  
}

output "DBServerPrivateIP" {
    description = "private ip address"
    value = aws_instance.vprofile-dbserver.private_ip
  
}

output "MQServerPrivateIP" {
    description = "private ip address"
    value = aws_instance.vprofile-mqserver.private_ip
  
}

output "MemCServerPrivateIP" {
    description = "private ip address"
    value = aws_instance.vprofile-memecache.private_ip
  
}

