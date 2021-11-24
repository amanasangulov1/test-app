resource "aws_eks_cluster" "selected" {
  name     = var.eks_cluster_name
  version  = var.eks_cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]
    subnet_ids         = [aws_subnet.eks_public_subnet[0].id, aws_subnet.eks_public_subnet[1].id, aws_subnet.eks_public_subnet[2].id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_amazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_amazonEKSVPCResourceController,
    aws_subnet.eks_public_subnet,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.selected.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.selected.certificate_authority[0].data
}