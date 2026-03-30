# Trust policy allowing EC2 instances to use this role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM role shared by all EC2 instances in the K3s cluster
resource "aws_iam_role" "ec2_node_role" {
  name               = "preg-ec2-node-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Allow EC2 instances to connect through AWS Systems Manager
resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Instance profile used by all EC2 nodes in the K3s cluster
resource "aws_iam_instance_profile" "ec2_node_profile" {
  name = "preg-ec2-node-profile"
  role = aws_iam_role.ec2_node_role.name
}