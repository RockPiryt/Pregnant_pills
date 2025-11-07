data "aws_ami" "debian" {
  most_recent      = true
  owners           = ["136693071363"] #id owner (amazon)z ami

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"] #skopiowana nazwa z ami
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# private cloud
resource "aws_vpc" "preg_vpc" {
  cidr_block       = "10.1.0.0/12"
  enable_dns_support  = true
  enable_dns_hostnames = true
}

#  podział na podsieci
resource "aws_subnet" "main-preg" {
  vpc_id     = aws_vpc.preg_vpc.id
  cidr_block = cidrsubnet(aws_vpc.preg_spot.cidr_block, 3, 1)
  availability_zone =  var.region
}

# do przyjecia ruchu z zewnatrz
resource "aws_internet_gateway" "gw-preg" {
  vpc_id = aws_vpc.preg_vpc.id
}

# tablica routingu
resource "aws_route_table" "rt-preg" {
  vpc_id = aws_vpc.preg_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-preg.id
  }
}

# security group  ssh - zezwolenie na dostep do instancji
resource "aws_security_group" "ssh" {
  name = "allow-all"

  vpc_id = aws_vpc.preg_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

# powiązanie route table z subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main-preg.id
  route_table_id = aws_route_table.rt-preg.id
}


resource "aws_spot_instance_request" "preg_spot" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"
}