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

# dodanie sg dla ssh
resource "aws_security_group" "ssh_preg" {
  name = "allow-all"

  vpc_id = aws_vpc.preg_vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
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

# dodanie klluczy do logowania
resource "aws_key_pair" "preg_key_pair" {
  key_name   = "preg-key"
  public_key = file(var.ssh_pub_key)
}

resource "aws_spot_instance_request" "preg_spot" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"
  
  key_name                    = resource.aws_key_pair.preg_key_pair.key_name
  wait_for_fulfillment        = true
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.ssh_preg.id}"]
  subnet_id = aws_subnet.main_preg.id

  user_data_base64 = base64encode(file("${path.module}/scripts/provsion_basic.sh"))

  tags = {
    Name = "Preg-Spot"
  }
}

# Create a terracurl request to check if the web server is up and running
# Wait a max of 20 minutes with a 10 second interval
resource "terracurl_request" "preg-terracurl" {
  name   = "preg-terracurl"
  url    = "http://${aws_spot_instance_request.preg_spot.public_ip}"
  method = "GET"

  response_codes = [200]
  max_retry      = 120
  retry_interval = 10
}