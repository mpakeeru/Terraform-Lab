# generate inventory file for Ansible
resource "local_file" "hosts_cfg" {
  content = templatefile("inventory.tpl",
    {
      app_servers = aws_instance.simplewebapp-appserver.*.public_ip
    }
  )
  filename = "aws_hosts"
}