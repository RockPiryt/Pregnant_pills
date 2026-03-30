output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_oidc_issuer" {
  value = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "node_security_group_id" {
  value = aws_security_group.eks_nodes_sg.id
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.eks.name}"
}