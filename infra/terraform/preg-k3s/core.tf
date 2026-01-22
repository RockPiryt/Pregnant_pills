# ===============================
# CORE INFRA (bezpłatne zasoby)
# ===============================

# private cloud
resource "aws_vpc" "preg_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support  = true
  enable_dns_hostnames = true
}

# podział na 8 podsieci
resource "aws_subnet" "main_preg" {
  vpc_id     = aws_vpc.preg_vpc.id
  cidr_block = cidrsubnet(aws_vpc.preg_vpc.cidr_block, 3, 1)
  availability_zone =  var.az
}

# utworzenie gateway (dostęp z zewnątrz)
resource "aws_internet_gateway" "gw_preg" {
  vpc_id = aws_vpc.preg_vpc.id
}

# dodanie tablicy routingu
resource "aws_route_table" "route_tb_preg" {
  vpc_id = aws_vpc.preg_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_preg.id
  }
}

# powiązanie tabeli routingu z podsiecią
resource "aws_route_table_association" "as_preg" {
  subnet_id      = aws_subnet.main_preg.id
  route_table_id = aws_route_table.route_tb_preg.id
}

data "http" "myip" {
  url = "https://checkip.amazonaws.com"
} 

# sg dla ssh
resource "aws_security_group" "ssh_preg" {
  name = "allow-all"

  vpc_id = aws_vpc.preg_vpc.id

  ingress {
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

# sg dla portu 80
resource "aws_security_group" "http_preg" {
  name = "allow-all-http"

  vpc_id = aws_vpc.preg_vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# dodanie klucza do logowania, Klucz publiczny do SSH
resource "aws_key_pair" "preg_key_pair2" {
  key_name   = "preg-key-2"
  public_key = file(var.ssh_pub_key)
}