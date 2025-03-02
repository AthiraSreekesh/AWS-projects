# Creates an AWS VPC with the specified CIDR block and enables DNS support and hostnames.
# 
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}
#
# Creates an AWS Internet Gateway and attaches it to the specified VPC.
# 
# Arguments:
#   vpc_id - The ID of the VPC to which the Internet Gateway will be attached.
#
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}
#
# Creates multiple public subnets within a specified VPC.
# Arguments:
# - map_public_ip_on_launch: Boolean flag to automatically assign a public IP to instances launched in the subnet.
#
resource "aws_subnet" "public-subnets" {
  count                   = var.public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, var.new_bits, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
  }
}


# Creates multiple private subnets within a specified VPC.
# 
# Arguments:
# - map_public_ip_on_launch: Set to `false` to ensure that instances launched in this subnet do not receive a public IP address.
#
resource "aws_subnet" "private-subnets" {
  count                   = var.private_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, var.new_bits, count.index + var.public_subnets)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.environment}-private-${count.index + 1}"
  }
}

# This resource allocates an Elastic IP (EIP) for use with a Network Gateway (NGW) in the specified VPC.
# The 'domain' attribute is set to "vpc" to indicate that the EIP is for use in a VPC.

resource "aws_eip" "ngw_ip" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}

# This resource block defines an AWS NAT Gateway.
# 
# The NAT Gateway is associated with an Elastic IP (EIP) and a public subnet.
# 
# - `allocation_id`: The ID of the Elastic IP to associate with the NAT Gateway.
# - `subnet_id`: The ID of the public subnet in which to create the NAT Gateway.
# 
# The `depends_on` argument ensures that the NAT Gateway is created only after the Internet Gateway (IGW) for the VPC is created, ensuring proper resource ordering.
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw_ip.id
  subnet_id     = aws_subnet.public-subnets[0].id

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Creates a public route table for the specified VPC.
# The route table includes a route that directs all traffic (0.0.0.0/0)
# to the internet gateway, allowing instances in the VPC to communicate
# with the internet.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public"
  }
}

# Creates a private route table for the specified VPC.
# 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-private"
  }
}

# Associates each public subnet with the public route table.
# 
resource "aws_route_table_association" "public_rt" {
  count          = var.public_subnets
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associates private subnets with the specified route table.
# 
resource "aws_route_table_association" "private_rt" {
  count          = var.private_subnets
  subnet_id      = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.private.id
}