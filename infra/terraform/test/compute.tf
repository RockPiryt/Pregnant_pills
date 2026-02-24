# COMPUTE (paid)

# Find latest Debian 11
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

# EC2 in public subnet
resource "aws_spot_instance_request" "preg_spot" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.small"
  
  key_name                    = resource.aws_key_pair.preg_key_pair2.key_name
  wait_for_fulfillment        = true
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.ssh_preg.id,
    aws_security_group.ingress_preg.id
  ]
  
  subnet_id = aws_subnet.main_preg.id

  user_data = templatefile("${path.module}/scripts/install_k3s.sh", {})

  tags = {
    Name = "Preg-Spot"
  }
}