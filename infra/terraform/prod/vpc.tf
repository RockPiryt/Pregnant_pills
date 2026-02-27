# Virtual private cloud
resource "aws_vpc" "preg-vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support  = true
  enable_dns_hostnames = true
}

# PUBLIC subnet (NAT)
resource "aws_subnet" "preg-public-subnet" {
  vpc_id                  = aws_vpc.preg-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.preg-vpc.cidr_block, 4, 0)
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = { Name = "preg-public-subnet" }
}

# PRIVATE subnet
resource "aws_subnet" "preg-private-subnet" {
  vpc_id                  = aws_vpc.preg-vpc.id
  availability_zone       ="eu-west-1a"
  cidr_block              = cidrsubnet(aws_vpc.preg-vpc.cidr_block, 4, 1)
  map_public_ip_on_launch = false

  tags = { Name = "preg-private-subnet" }
}

# Internet Gateway public
resource "aws_internet_gateway" "igw-preg" {
  vpc_id = aws_vpc.preg-vpc.id
  tags = { Name = "igw-preg" }
}

# --------------------------------Route tables + associations
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
  subnet_id      = aws_subnet.preg-public-subnet.id
  route_table_id = aws_route_table.preg-rt-public.id
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
  subnet_id      = aws_subnet.preg-private-subnet.id
  route_table_id = aws_route_table.preg-rt-private.id
}

# --------------------------------NAT + EIP
# NAT Gateway
resource "aws_nat_gateway" "preg-nat" {
  allocation_id = aws_eip.preg-nat-eip.id
  subnet_id     = aws_subnet.preg-public-subnet.id

  depends_on = [aws_internet_gateway.igw-preg]

  tags = { Name = "preg-nat" }
}

# EIP for NAT
resource "aws_eip" "preg-nat-eip" {
  domain = "vpc"
  tags = { Name = "preg-nat-eip" }
}

# --------------------------------RDS Postgres
resource "aws_db_subnet_group" "preg_db_subnet_group" {
  name       = "preg-db-subnet-group"
  subnet_ids = [aws_subnet.preg-private-subnet.id]

  tags = {
    Name = "preg-db-subnet-group"
  }
}