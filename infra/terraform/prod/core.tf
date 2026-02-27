# CORE INFRA (free)

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
  subnet_id      = aws_subnet.preg-public-subnet.id
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
  subnet_id     = aws_subnet.preg-public-subnet.id

  depends_on = [aws_internet_gateway.igw-preg]

  tags = { Name = "preg-nat" }
}

# PRIVATE subnet
resource "aws_subnet" "preg-private-subnet" {
  vpc_id                  = aws_vpc.preg-vpc.id
  availability_zone       ="eu-west-1a"
  cidr_block              = cidrsubnet(aws_vpc.preg-vpc.cidr_block, 4, 1)
  map_public_ip_on_launch = false

  tags = { Name = "preg-private-subnet" }
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

# ALB SG
resource "aws_security_group" "alb_preg" {
  name        = "preg-alb"
  description = "Allowing HTTP/HTTPS from the internet"
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

# Security group for K3s master and worker nodes
resource "aws_security_group" "k3s_nodes_sg" {
  name        = "preg-k3s-nodes"
  description = "Security group for K3s master/worker nodes"
  vpc_id      = aws_vpc.preg-vpc.id

  # Allow full traffic between nodes inside the same SG
  ingress {
    description = "Node-to-node communication within K3s cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Explicit Kubernetes API access
  ingress {
    description = "Kubernetes API (worker -> master)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    self        = true
  }

  # Allow ALB to access NodePort exposed by Kubernetes service
  ingress {
    description     = "Allow ALB to access NodePort 30080"
    from_port       = 30080
    to_port         = 30080
    protocol        = "tcp"
    security_groups = [aws_security_group.ingress_preg.id]
  }

  # Allow outbound internet access (via NAT Gateway). Required for Docker Hub pulls, OS updates, etc.
  egress {
    description = "Allow outbound traffic to the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "preg-k3s-nodes" }
}

# Application Load Balancer (public-facing)
resource "aws_lb" "preg_alb" {
  name               = "preg-alb"
  load_balancer_type = "application"
  internal           = false

  subnets         = [aws_subnet.preg-public-subnet.id] # public subnet
  security_groups = [aws_security_group.alb_preg.id]

}

# Target Group pointing to EC2 instances (NodePort 30080)
resource "aws_lb_target_group" "preg_tg" {
  name        = "preg-tg"
  port        = 30080 
  protocol    = "HTTP"
  vpc_id      = aws_vpc.preg-vpc.id
  target_type = "instance" # Targets are EC2 instances

  # Health check configuration
  health_check {
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "preg_http" {
  load_balancer_arn = aws_lb.preg_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.preg_tg.arn
  }
}
