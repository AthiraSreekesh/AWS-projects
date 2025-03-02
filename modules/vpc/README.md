### VPC Creation Terraform Module

This Terraform module creates an AWS VPC with public and private subnets, an Internet Gateway, a NAT Gateway, and associated route tables.

## Variables

- `project_name`: (string) Project tag value.
- `environment`: (string) Environment tag value.
- `cidr_block`: (string) CIDR block of the VPC.
- `public_subnets`: (string) Number of public subnets.
- `private_subnets`: (string) Number of private subnets.
- `new_bits`: (string) New bits to be added for subnetting.

## Resources

### VPC

Creates an AWS VPC with the specified CIDR block and enables DNS support and hostnames.

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}
```

### Internet Gateway

Creates an AWS Internet Gateway and attaches it to the specified VPC.

```hcl
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}
```

### Public Subnets

Creates multiple public subnets within the specified VPC.

```hcl
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
```

### Private Subnets

Creates multiple private subnets within the specified VPC.

```hcl
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
```

### Elastic IP

Allocates an Elastic IP (EIP) for use with a Network Gateway (NGW) in the specified VPC.

```hcl
resource "aws_eip" "ngw_ip" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}
```

### NAT Gateway

Defines an AWS NAT Gateway associated with an Elastic IP (EIP) and a public subnet.

```hcl
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw_ip.id
  subnet_id     = aws_subnet.public-subnets[0].id

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }

  depends_on = [aws_internet_gateway.igw]
}
```

### Route Tables

Creates public and private route tables for the specified VPC.

```hcl
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
```

### Route Table Associations

Associates each public and private subnet with the respective route tables.

```hcl
resource "aws_route_table_association" "public_rt" {
  count          = var.public_subnets
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_rt" {
  count          = var.private_subnets
  subnet_id      = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.private.id
}
```

## Outputs

- `private_subnet`: Outputs the CIDR block of the private subnet.

```hcl
output "private_subnet" {
  value = cidrsubnet(var.cidr_block, 3, 0)
}
```
```