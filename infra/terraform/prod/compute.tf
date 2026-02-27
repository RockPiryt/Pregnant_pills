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

# K3s master (private subnet)
resource "aws_instance" "k3s_master" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.small"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.preg-private-subnet.id

  vpc_security_group_ids = [aws_security_group.k3s_nodes_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = templatefile("${path.module}/scripts/install_k3s_master.sh", {
    K3S_TOKEN       = var.k3s_token
    MASTER_TLS_SAN  = aws_instance.k3s_master.private_ip
  })

  tags = { Name = "preg-k3s-master" }
}

# K3s worker (private subnet)
resource "aws_instance" "k3s_worker" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.small"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.preg-private-subnet.id

  vpc_security_group_ids = [aws_security_group.k3s_nodes_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = templatefile("${path.module}/scripts/install_k3s_worker.sh", {
    K3S_TOKEN   = var.k3s_token
    MASTER_IP   = aws_instance.k3s_master.private_ip
  })

  depends_on = [aws_instance.k3s_master] # first master, then worker

  tags = { Name = "preg-k3s-worker" }
}


# Target group - master node
resource "aws_lb_target_group_attachment" "master" {
  target_group_arn = aws_lb_target_group.preg_tg.arn
  target_id        = aws_instance.k3s_master.id
  port             = 30080
}
# Target group - worker node
resource "aws_lb_target_group_attachment" "worker" {
  target_group_arn = aws_lb_target_group.preg_tg.arn
  target_id        = aws_instance.k3s_worker.id
  port             = 30080
}