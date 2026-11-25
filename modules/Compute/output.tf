output "eks_cluster_endpoint" {
  value = "aws_eks_cluster.marefiya_eks_cluster.endpoint"
}
output "eks_cluster_certificate" {
  value = aws_eks_cluster.marefiya_eks_cluster.certificate_authority[0].data
}

output "eks_cluster_name" {
  value = "aws_eks_cluster_name.marefiya_eks_cluster_name.name"
}