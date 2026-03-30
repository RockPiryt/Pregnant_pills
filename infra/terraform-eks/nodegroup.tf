resource "aws_key_pair" "pregcare-key" {
  key_name   = var.key_pair_name
  public_key = var.ssh_pub_key
}

# Create template for EC2 worker nodes
resource "aws_launch_template" "eks_nodes_lt" {
  name_prefix            = "${var.cluster_name}-lt-"
  key_name               = aws_key_pair.pregcare-key.key_name
  update_default_version = true

  # Add sg for nodes
  vpc_security_group_ids = [aws_security_group.eks_nodes_sg.id]

  # Set size and disc type for worker nodes.
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  # Add tags for EC2 instances,which are created by node group
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.cluster_name}-worker-node"
    }
  }
}

# Create node group for worker nodes
resource "aws_eks_node_group" "public_ng" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  # Define instance
  instance_types = [var.instance_type]
  capacity_type  = "ON_DEMAND"

  # instance_types = ["t3.medium", "t3a.medium"]
  # capacity_type  = "SPOT"

  # Autoscaling node group (currently 2/2/2)
  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  # Use launch template to config instances
  launch_template {
    id      = aws_launch_template.eks_nodes_lt.id
    version = aws_launch_template.eks_nodes_lt.latest_version
  }

  # Wait for IAM roles before creating node group
  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_readonly,
    aws_iam_role_policy_attachment.asg_full_access,
    aws_iam_role_policy_attachment.route53_full_access,
    aws_iam_role_policy_attachment.ecr_full_access,
    aws_iam_role_policy_attachment.appmesh_full_access,
    aws_iam_role_policy_attachment.elb_full_access
  ]

  tags = {
    Name = var.node_group_name
  }
}