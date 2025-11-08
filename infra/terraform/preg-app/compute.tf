# ===============================
# COMPUTE (płatne zasoby)
# ===============================

# Wyszukanie najnowszego obrazu Debian 11
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


resource "aws_spot_instance_request" "preg_spot" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"
  
  key_name                    = resource.aws_key_pair.preg_key_pair.key_name
  wait_for_fulfillment        = true
  associate_public_ip_address = true
  security_groups = [
    aws_security_group.ssh_preg.id,
    aws_security_group.http_preg.id
  ]
  subnet_id = aws_subnet.main_preg.id

  user_data_base64 = base64encode(file("${path.module}/scripts/provision_basic.sh"))

  

  tags = {
    Name = "Preg-Spot"
  }
}

# Create a terracurl request to check if the web server is up and running
# sprawdzam czy instancja dla web servera jest juz gotowa, Sprawdzenie działania serwera HTTP
# Wait a max of 20 minutes with a 10 second interval
resource "terracurl_request" "preg-terracurl" {
  name   = "preg-terracurl"
  url    = "http://${aws_spot_instance_request.preg_spot.public_ip}"
  method = "GET"

  response_codes = [200]
  max_retry      = 120
  retry_interval = 10
}