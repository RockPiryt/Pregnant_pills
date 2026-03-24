# CORE INFRA (free)

# Virtual private cloud
resource "aws_vpc" "preg_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support  = true
  enable_dns_hostnames = true
}

# PUBLIC subnet
resource "aws_subnet" "main_preg" {
  vpc_id                  = aws_vpc.preg_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.preg_vpc.cidr_block, 3, 1)
  availability_zone       = var.az
  map_public_ip_on_launch = true
}

# # Internet Gateway public
resource "aws_internet_gateway" "gw_preg" {
  vpc_id = aws_vpc.preg_vpc.id
}

# Route Table public
resource "aws_route_table" "route_tb_preg" {
  vpc_id = aws_vpc.preg_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_preg.id
  }
}

# Association Route Table with public rt
resource "aws_route_table_association" "as_preg" {
  subnet_id      = aws_subnet.main_preg.id
  route_table_id = aws_route_table.route_tb_preg.id
}

data "http" "myip" {
  url = "https://checkip.amazonaws.com"
} 

# SG (ssh)
resource "aws_security_group" "ssh_preg" {
  name        = "preg-ssh"
  description = "SSH tylko z mojego IP"
  vpc_id      = aws_vpc.preg_vpc.id

  ingress {
    description = "SSH from my IP"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "preg-ssh" }
}

# SG (ingress)
resource "aws_security_group" "ingress_preg" {
  name        = "preg-ingress"
  description = "Public HTTP/HTTPS dla ingress"
  vpc_id      = aws_vpc.preg_vpc.id

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

# Key pair to SSH
resource "aws_key_pair" "preg_key_pair2" {
  key_name   = "preg-key-2-pkimak"
  public_key = file(var.ssh_pub_key)
}

# Elastic IP (fix IP for spot instance)
resource "aws_eip" "preg_eip" {
  domain = "vpc"
  tags = { Name = "preg-eip" }
}
# Association EIP with spot instance
resource "aws_eip_association" "preg_assoc" {
  instance_id   = aws_spot_instance_request.preg_spot.spot_instance_id
  allocation_id = aws_eip.preg_eip.id
}

