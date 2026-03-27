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

# Existing IAM policy for AWS Load Balancer Controller
data "aws_iam_policy" "aws_load_balancer_controller" {
  name = "AWSLoadBalancerControllerIAMPolicy"
}

# Allow cluster nodes to manage AWS load balancers via AWS Load Balancer Controller
resource "aws_iam_role_policy_attachment" "ec2_alb_controller" {
  role       = aws_iam_role.ec2_node_role.name
  policy_arn = data.aws_iam_policy.aws_load_balancer_controller.arn
}

# Allow ExternalDNS to manage Route53 DNS records
resource "aws_iam_role_policy" "ec2_route53_policy" {
  name = "ExternalDNSRoute53Policy"
  role = aws_iam_role.ec2_node_role.id

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

# AWS Cloud Controller Manager (CCM)
resource "aws_iam_role_policy" "ec2_aws_ccm_policy" {
  name = "AWSCloudControllerManagerPolicy"
  role = aws_iam_role.ec2_node_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Autoscaling (node discovery)
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",

          # EC2 core (CRITICAL for providerID)
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVpcs",

          # EC2 mutations (network reconcile)
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:ModifyInstanceAttribute",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",

          # ELB (classic + v2)
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",

          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",

          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyListener",

          # Required for ELB service-linked role
          "iam:CreateServiceLinkedRole",

          # Optional but safe
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Instance profile used by all EC2 nodes in the K3s cluster
resource "aws_iam_instance_profile" "ec2_node_profile" {
  name = "preg-ec2-node-profile"
  role = aws_iam_role.ec2_node_role.name
}