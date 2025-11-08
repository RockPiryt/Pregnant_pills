# Minimalny przykład
resource "aws_key_pair" "demo_key" {
  key_name   = "demo-key"
  public_key = file(var.ssh_pub_key)
}

resource "aws_security_group" "k3s_sg" {
  name   = "k3s-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k3s_node" {
  ami                    = data.aws_ami.debian.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.demo_key.key_name
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | sh -
    # poczekaj na start
    sleep 30
    cat <<YAML >/tmp/app.yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: demo
    spec:
      containers:
      - name: demo
        image: nginx:alpine
        ports:
        - containerPort: 80
    YAML
    k3s kubectl apply -f /tmp/app.yaml
  EOF

  tags = { Name = "K3s-demo" }
}

output "k3s_public_ip" {
  value = aws_instance.k3s_node.public_ip
}
