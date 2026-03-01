# COMPUTE (paid)

# Find latest Debian 11
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

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
  subnet_id                   = aws_subnet.preg-private-subnet-a.id

  vpc_security_group_ids = [aws_security_group.k3s_nodes_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = templatefile("${path.module}/scripts/install_k3s_master.sh", {
    K3S_TOKEN      = var.k3s_token
    MASTER_TLS_SAN = "127.0.0.1"
  })

  tags = { Name = "preg-k3s-master" }
}

# K3s worker A (private subnet A)
resource "aws_instance" "k3s_worker_a" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.small"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.preg-private-subnet-a.id

  vpc_security_group_ids = [aws_security_group.k3s_nodes_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = templatefile("${path.module}/scripts/install_k3s_worker.sh", {
    K3S_TOKEN = var.k3s_token
    MASTER_IP = aws_instance.k3s_master.private_ip
  })

  depends_on = [aws_instance.k3s_master]

  tags = { Name = "preg-k3s-worker-a" }
}

# K3s worker B (private subnet B)
resource "aws_instance" "k3s_worker_b" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.small"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.preg-private-subnet-b.id

  vpc_security_group_ids = [aws_security_group.k3s_nodes_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = templatefile("${path.module}/scripts/install_k3s_worker.sh", {
    K3S_TOKEN = var.k3s_token
    MASTER_IP = aws_instance.k3s_master.private_ip
  })

  depends_on = [aws_instance.k3s_master]

  tags = { Name = "preg-k3s-worker-b" }
}


# Attach worker A  node to target group
resource "aws_lb_target_group_attachment" "worker_a" {
  target_group_arn = aws_lb_target_group.preg_tg.arn
  target_id        = aws_instance.k3s_worker_a.id
  port             = 30080
}

# Attach worker B node to target group
resource "aws_lb_target_group_attachment" "worker_b" {
  target_group_arn = aws_lb_target_group.preg_tg.arn
  target_id        = aws_instance.k3s_worker_b.id
  port             = 30080
}

# RDS PostgreSQL
resource "aws_db_instance" "preg_postgres" {
  identifier        = "preg-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "pregdb"
  username = var.db_username
  password = var.db_password

  publicly_accessible = false
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.preg_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.preg_db_subnet_group.name

  backup_retention_period = 0 # dev only

  tags = {
    Name = "preg-postgres"
  }
}