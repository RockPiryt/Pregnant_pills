data "aws_ami" "debian" {
  most_recent      = true
  owners           = ["136693071363"] id owner (amazon)z ami

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"] skopiowana nazwa z ami
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

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.preg_vpc.id
  cidr_block = cidrsubnet(aws_vpc.preg_spot.cidr_block, 3, 1)
  availability_zone =  var.region
}

resource "aws_spot_instance_request" "preg_spot" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"
}