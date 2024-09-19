resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project_name}-${var.eks_cluster_name}"
  role_arn = aws_iam_role.eks_cluster_service_role.arn
  version  = var.k8s_version

  upgrade_policy {
    support_type = "STANDARD"
  }
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = [for subnet in aws_subnet.private_subnets : subnet.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.eks_cluster_name}"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_policy_1,
    aws_iam_role_policy_attachment.eks_cluster_role_policy_2
  ]
}