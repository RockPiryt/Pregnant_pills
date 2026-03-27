# -------------------------Security group for K3s master and worker nodes
resource "aws_security_group" "k3s_nodes_sg" {
  name        = "preg-k3s-nodes"
  description = "Security group for K3s master/worker nodes"
  vpc_id      = aws_vpc.preg-vpc.id

  # Allow full traffic between nodes inside the same SG
  ingress {
    description = "Node-to-node communication within K3s cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Explicit Kubernetes API access
  ingress {
    description = "Kubernetes API (worker to master)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    self        = true
  }

  # Allow outbound internet access (via NAT Gateway). Required for Docker Hub pulls, OS updates, etc.
  egress {
    description = "Allow outbound traffic to the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "preg-k3s-nodes" }
}

# -------------------------RDS SG
resource "aws_security_group" "preg_rds_sg" {
  name        = "preg-rds-sg"
  description = "Allow Postgres access from K3s nodes only"
  vpc_id      = aws_vpc.preg-vpc.id

  ingress {
    description     = "Postgres from k3s nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.k3s_nodes_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "k3s_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s_nodes_sg.id
}

resource "aws_security_group_rule" "k3s_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s_nodes_sg.id
}
