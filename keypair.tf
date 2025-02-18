# Creating SSH key for the servers

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0400"
  filename        = "${path.module}/ssh-key.pem"
}

resource "local_file" "ssh_public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "${path.module}/ssh-key.pub"
}

# Creating the key pair in aws using the SSH key created

resource "aws_key_pair" "ssh_key" {
  key_name_prefix = var.project_name
  public_key      = local_file.ssh_public_key.content
  tags = {
    "Name" = var.project_name
  }
}