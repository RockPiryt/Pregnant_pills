# EKS cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  # Define vpc and sg
  vpc_config {
    subnet_ids = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id,
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]
    endpoint_private_access = true # aby nodes w private subnet mogly gadać z API serverem (bez przechodzenia przez NAT)
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  # Depend on IAM cluster role
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = {Name = var.cluster_name}
}

# To enable and use AWS IAM roles for Kubernetes service accounts on our EKS cluster, 
# I must create & associate OIDC identity provider.

# Get tls cert
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# Create & associate OIDC identity provider.
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}