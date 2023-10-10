# RSA key of size 4096 bits
resource "tls_private_key" "rsa-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Save the key.pem file in local directory

resource "local_file" "test-key-private" {
  content  = tls_private_key.rsa-private-key.private_key_pem
  filename = "test-key.pem"
}

# Create AWS key_pair

resource "aws_key_pair" "test-key" {
  key_name   = "test-key"
  public_key = tls_private_key.rsa-private-key.public_key_openssh
}