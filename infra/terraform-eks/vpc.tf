resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

# -------------------------
# Public subnets
# -------------------------
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_cidr_a
  availability_zone       = var.az_a
  map_public_ip_on_launch = true

  tags = {
    Name                                  = "${var.cluster_name}-public-a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared" # cluster może znać wszystkie subnety
    "kubernetes.io/role/elb"              = "1" # LB public in public subnet 
    kubernetes.io/role/internal-elb = 1 #LB internal in  private  subnet
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_cidr_b
  availability_zone       = var.az_b
  map_public_ip_on_launch = true

  tags = {
    Name                                  = "${var.cluster_name}-public-b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }
}

# -------------------------
# Private subnets
# -------------------------
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.private_subnet_cidr_a
  availability_zone       = var.az_a
  map_public_ip_on_launch = false

  tags = {
    Name                                  = "${var.cluster_name}-private-a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.private_subnet_cidr_b
  availability_zone       = var.az_b
  map_public_ip_on_launch = false

  tags = {
    Name                                  = "${var.cluster_name}-private-b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }
}

# -------------------------
# Public route table
# -------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------
# NAT EIPs
# -------------------------
resource "aws_eip" "nat_eip_a" {
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-nat-eip-a"
  }
}

resource "aws_eip" "nat_eip_b" {
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-nat-eip-b"
  }
}

# -------------------------
# NAT Gateways
# -------------------------
resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.public_a.id
  depends_on    = [aws_internet_gateway.eks_igw]

  tags = {
    Name = "${var.cluster_name}-nat-a"
  }
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_eip_b.id
  subnet_id     = aws_subnet.public_b.id
  depends_on    = [aws_internet_gateway.eks_igw]

  tags = {
    Name = "${var.cluster_name}-nat-b"
  }
}

# -------------------------
# Private route tables
# -------------------------
resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt-a"
  }
}

resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt-b"
  }
}

resource "aws_route_table_association" "private_a_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt_a.id
}

resource "aws_route_table_association" "private_b_assoc" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt_b.id
}