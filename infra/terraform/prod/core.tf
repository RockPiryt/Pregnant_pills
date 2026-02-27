# CORE INFRA (free)

# Avability Zones
variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}

# Virtual private cloud
resource "aws_vpc" "preg-vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support  = true
  enable_dns_hostnames = true
}
# PUBLIC subnet (NAT / bastion)
resource "aws_subnet" "preg-public-subnet-az1" {
  vpc_id                  = aws_vpc.preg-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.preg-vpc.cidr_block, 4, 0)
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true

  tags = { Name = "preg-public-subnet-az1" }
}

# Internet Gateway public
resource "aws_internet_gateway" "igw-preg" {
  vpc_id = aws_vpc.preg-vpc.id
  tags = { Name = "igw-preg" }
}

# Route Table public
resource "aws_route_table" "preg-rt-public" {
  vpc_id = aws_vpc.preg-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-preg.id
  }

  tags = { Name = "preg-rt-public" }
}

# Association Route Table with public rt
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.preg-public-subnet-az1.id
  route_table_id = aws_route_table.preg-rt-public.id
}

# EIP for NAT
resource "aws_eip" "preg-nat-eip" {
  domain = "vpc"
  tags = { Name = "preg-nat-eip" }
}

# NAT Gateway
resource "aws_nat_gateway" "preg-nat" {
  allocation_id = aws_eip.preg-nat-eip.id
  subnet_id     = aws_subnet.preg-public-subnet-az1.id

  depends_on = [aws_internet_gateway.igw-preg]

  tags = { Name = "preg-nat" }
}

# PRIVATE subnets (2 AZ)
resource "aws_subnet" "preg-private-subnet-2azs" {
  for_each = toset(var.azs)

  vpc_id                  = aws_vpc.preg-vpc.id
  availability_zone       = each.value
  cidr_block              = cidrsubnet(aws_vpc.preg-vpc.cidr_block, 4, 10 + index(var.azs, each.value))
  map_public_ip_on_launch = false

  tags = { Name = "preg-private-subnet-${each.value}" }
}

# Route Table private
resource "aws_route_table" "preg-rt-private" {
  vpc_id = aws_vpc.preg-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.preg-nat.id
  }

  tags = { Name = "preg-rt-private" }
}

# Association Route Table with private rt
resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.preg-private-subnet-2azs

  subnet_id      = each.value.id
  route_table_id = aws_route_table.preg-rt-private.id
}

# ingress sg
resource "aws_security_group" "ingress_preg" {
  name        = "preg-ingress"
  description = "Public HTTP/HTTPS dla ingress"
  vpc_id      = aws_vpc.preg-vpc.id

  ingress {
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    description = "HTTPS"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "preg-ingress" }
}
