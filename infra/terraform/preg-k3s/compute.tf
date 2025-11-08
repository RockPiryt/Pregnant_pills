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


locals {
  k3s_manifests = fileset("${path.module}/k3s", "*.yaml")
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

  user_data = templatefile("${path.module}/scripts/install_k3s.sh", {
    manifests = [for f in local.k3s_manifests : {
      name = basename(f)
      content = file("${path.module}/k3s/${f}")
    }]
  })

  tags = {
    Name = "Preg-Spot"
  }
}