# CORE INFRA (bezpłatne zasoby)

# private cloud
resource "aws_vpc" "preg_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support  = true
  enable_dns_hostnames = true
}

# podział na 8 podsieci
resource "aws_subnet" "main_preg" {
  vpc_id                  = aws_vpc.preg_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.preg_vpc.cidr_block, 3, 1)
  availability_zone       = var.az
  map_public_ip_on_launch = true
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


# aplikacja przez NodePort: np. 30080
resource "aws_security_group" "nodeport_preg" {
  name   = "allow-nodeport"
  vpc_id = aws_vpc.preg_vpc.id

  ingress {
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ingress sg
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

# dodanie klucza do logowania, Klucz publiczny do SSH
resource "aws_key_pair" "preg_key_pair2" {
  key_name   = "preg-key-2-pkimak"
  public_key = file(var.ssh_pub_key)
}

# tworzenie stałego publicznego IP(bo spot może mieć zmienne IP)
resource "aws_eip" "preg_eip" {
  tags = { Name = "preg-eip" }
}
# powiązanie EIP z instacja spot
resource "aws_eip_association" "preg_assoc" {
  instance_id   = aws_spot_instance_request.preg_spot.spot_instance_id
  allocation_id = aws_eip.preg_eip.id
}
#utworzenie rekordu dns dla EIP
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.pk_domain.zone_id
  name    = "paulinakimak.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.preg_eip.public_ip]
}
