# Virtual private cloud
resource "aws_vpc" "preg-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# PUBLIC subnet A (NAT)
resource "aws_subnet" "preg-public-subnet-a" {
  vpc_id                  = aws_vpc.preg-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.preg-vpc.cidr_block, 4, 0)
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = { Name = "preg-public-subnet-a" }
}

# PRIVATE subnet A
resource "aws_subnet" "preg-private-subnet-a" {
  vpc_id                  = aws_vpc.preg-vpc.id
  availability_zone       = "eu-west-1a"
  cidr_block              = cidrsubnet(aws_vpc.preg-vpc.cidr_block, 4, 1)
  map_public_ip_on_launch = false

  tags = { Name = "preg-private-subnet-a" }
}

# PUBLIC subnet B (ALB, second AZ)
resource "aws_subnet" "preg-public-subnet-b" {
  vpc_id                  = aws_vpc.preg-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.preg-vpc.cidr_block, 4, 2)
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = { Name = "preg-public-subnet-b" }
}

# PRIVATE subnet B (worker/RDS, second AZ)
resource "aws_subnet" "preg-private-subnet-b" {
  vpc_id                  = aws_vpc.preg-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.preg-vpc.cidr_block, 4, 3)
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = { Name = "preg-private-subnet-b" }
}
# Internet Gateway public
resource "aws_internet_gateway" "igw-preg" {
  vpc_id = aws_vpc.preg-vpc.id
  tags   = { Name = "igw-preg" }
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


# Route Table private A -> NAT A
resource "aws_route_table" "preg_rt_private_a" {
  vpc_id = aws_vpc.preg-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.preg_nat_a.id
  }

  tags = { Name = "preg-rt-private-a" }
}

# Route Table private B -> NAT B
resource "aws_route_table" "preg_rt_private_b" {
  vpc_id = aws_vpc.preg-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.preg_nat_b.id
  }

  tags = { Name = "preg-rt-private-b" }
}

# Associate private subnet A -> private RT A
resource "aws_route_table_association" "private_assoc_a" {
  subnet_id      = aws_subnet.preg-private-subnet-a.id
  route_table_id = aws_route_table.preg_rt_private_a.id
}

# Associate private subnet B -> private RT B
resource "aws_route_table_association" "private_assoc_b" {
  subnet_id      = aws_subnet.preg-private-subnet-b.id
  route_table_id = aws_route_table.preg_rt_private_b.id
}

# Association Route Table with public rt (AZ-a)
resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.preg-public-subnet-a.id
  route_table_id = aws_route_table.preg-rt-public.id
}


# Association Route Table with public rt (AZ-b)
resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.preg-public-subnet-b.id
  route_table_id = aws_route_table.preg-rt-public.id
}



# --------------------------------NAT + EIP
# EIP for NAT A
resource "aws_eip" "preg_nat_eip_a" {
  domain = "vpc"
  tags   = { Name = "preg-nat-eip-a" }
}

# NAT Gateway A (public subnet A)
resource "aws_nat_gateway" "preg_nat_a" {
  allocation_id = aws_eip.preg_nat_eip_a.id
  subnet_id     = aws_subnet.preg-public-subnet-a.id
  depends_on    = [aws_internet_gateway.igw-preg]
  tags          = { Name = "preg-nat-a" }
}

# EIP for NAT B
resource "aws_eip" "preg_nat_eip_b" {
  domain = "vpc"
  tags   = { Name = "preg-nat-eip-b" }
}

# NAT Gateway B (public subnet B)
resource "aws_nat_gateway" "preg_nat_b" {
  allocation_id = aws_eip.preg_nat_eip_b.id
  subnet_id     = aws_subnet.preg-public-subnet-b.id
  depends_on    = [aws_internet_gateway.igw-preg]
  tags          = { Name = "preg-nat-b" }
}

# --------------------------------RDS Postgres
resource "aws_db_subnet_group" "preg_db_subnet_group" {
  name = "preg-db-subnet-group"
  subnet_ids = [
    aws_subnet.preg-private-subnet-a.id,
    aws_subnet.preg-private-subnet-b.id
  ]

  tags = {
    Name = "preg-db-subnet-group"
  }
}