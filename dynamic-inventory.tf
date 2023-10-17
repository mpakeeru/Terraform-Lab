# generate inventory file for Ansible
resource "local_file" "hosts_cfg" {
  content = templatefile("inventory.tpl",
    {
      web_servers = aws_instance.vprofile-appserver.*.public_ip
      memcache_server = aws_instance.vprofile-memecache.*.private_ip
      db_server = aws_instance.vprofile-dbserver.*.private_ip
      mq_server = aws_instance.vprofile-mqserver.*.private_ip
    }
  )
  filename = "../ansible/inventory/aws_hosts"
}