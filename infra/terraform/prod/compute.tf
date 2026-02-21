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


# EC2 in private subnets
resource "aws_instance" "private_ec2" {
  count = 2
  ami                    = data.aws_ami.debian.id
  instance_type          = "t3.small"

  key_name               = resource.aws_key_pair.preg_key_pair2.key_name
  associate_public_ip_address = false
  
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]

  subnet_id              = element(values(aws_subnet.preg-private-subnet-2azs)[*].id, count.index)
  user_data = templatefile("${path.module}/scripts/install_k3s.sh", {})

  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  tags = {
    Name = "preg-private-ec2-${count.index + 1}"
  }
}

