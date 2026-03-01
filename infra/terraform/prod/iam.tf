# Trust policy to allow EC2 to use role
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

# Create ssm role for ec2
resource "aws_iam_role" "ec2_ssm_role" {
  name               = "preg-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Add policy to ssm_role
resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Add role to Instance Profile
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "preg-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}