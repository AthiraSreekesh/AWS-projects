output "vpc_id" {
    value = aws_vpc.main.id
}

# Output to list public and private subnet CIDRs
output "subnets" {
  value = {
    public_subnets = [
      for subnet in aws_subnet.public-subnets : subnet.cidr_block
    ]
    private_subnets = [
      for subnet in aws_subnet.private-subnets : subnet.cidr_block
    ]
  }
}