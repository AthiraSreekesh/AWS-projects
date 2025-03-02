output "vpc_id" {
  value = module.vpc.vpc_id
}

output "keypair_name" {
  value = module.aws_key_pair.key_name
}
output "public_subnet1" {
  value = module.vpc.subnets.public_subnets[0]
}
output "public_subnet2" {
  value = module.vpc.subnets.public_subnets[1]
}
output "public_subnet3" {
  value = module.vpc.subnets.public_subnets[2]
}

output "private_subnet1" {
  value = module.vpc.subnets.private_subnets[0]
}
output "private_subnet2" {
  value = module.vpc.subnets.private_subnets[1]
}
output "private_subnet3" {
  value = module.vpc.subnets.private_subnets[2]
}

