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

# Keypair Creation