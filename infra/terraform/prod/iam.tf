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

# Add policy (EC2 has necessary Route53 permissions)
resource "aws_iam_role_policy" "ec2_route53_policy" {
  name = "EC2Route53Policy"
  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}


# Add role to Instance Profile
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "preg-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}
