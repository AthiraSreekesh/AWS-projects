# VPC creation
module "vpc" {
  source          = "./modules/vpc"
  project_name    = var.project_name
  environment     = var.environment
  cidr_block      = var.cidr_block
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  new_bits        = var.new_bits
}

# Keypair creation

module "aws_key_pair" {
  source       = "./modules/keypair"
  project_name = var.project_name
  environment  = var.environment
}

resource "aws_security_group" "lamp_sgs" {

  for_each    = toset(var.names)
  name        = "${var.project_name}-${each.key}-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.project_name}-${each.key}"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

}


# SG inbound rule for bastion server:
# This section defines the security group inbound rules for the bastion server.
# It specifies the allowed inbound traffic to the bastion host, ensuring secure access.
# SG inbound rule for bastion server

resource "aws_security_group_rule" "ssh_bastion_sg_rule_dev" {
  count             = var.environment == "Development" ? 1 : 0
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lamp_sgs["bastion"].id
}

resource "aws_security_group_rule" "ssh_bastion_sg_rule_prod" {
  count             = var.environment == "Production" ? 1 : 0
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["167.103.6.209/32"]
  security_group_id = aws_security_group.lamp_sgs["bastion"]
}


# SG ssh inbound rule for web server

resource "aws_security_group_rule" "ssh_webserver_sg_rule_dev" {

  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = aws_security_group.lamp_sgs["bastion"].id
  security_group_id        = aws_security_group.lamp_sgs["webserver"].id
}

# SG ssh inbound rule for db server
resource "aws_security_group_rule" "ssh_db_sg_rule_prod" {

  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = aws_security_group.lamp_sgs["bastion"].id
  security_group_id        = aws_security_group.lamp_sgs["db"].id
}

# SG inbound rule for web server
resource "aws_security_group_rule" "webserver_sg_inbound_rule" {
  for_each          = toset(var.webserver_sg_ports)
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lamp_sgs["webserver"].id
}

# SG inbound rule for db server

resource "aws_security_group_rule" "db_server_sg_inbound_rule" {
  for_each                 = toset(var.db_sg_ports)
  from_port                = each.key
  to_port                  = each.key
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = aws_security_group.lamp_sgs["webserver"].id
  security_group_id        = aws_security_group.lamp_sgs["db"].id
}