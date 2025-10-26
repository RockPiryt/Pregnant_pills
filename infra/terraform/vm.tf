data "aws_ami" "debian" {
  most_recent      = true
  owners           = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "preg_vpc" {
  cidr_block       = "10.1.0.0/12"
  enable_dns_support  = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "main_preg" {
  vpc_id     = aws_vpc.preg_vpc.id
  cidr_block = cidrsubnet(aws_vpc.preg_vpc.cidr_block, 3, 1)
  availability_zone =  var.region
}

resource "aws_internet_gateway" "gw_preg" {
  vpc_id = aws_vpc.preg_vpc.id
}

resource "aws_route_table" "route_tb_preg" {
  vpc_id = aws_vpc.preg_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_preg.id
  }

}

resource "aws_route_table_association" "as_preg" {
  subnet_id      = aws_subnet.main_preg.id
  route_table_id = aws_route_table.route_tb_preg.id
}

resource "aws_spot_instance_request" "preg_spot" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"

  tags = {
    Name = "Preg-Spot"
  }
}