resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project_name}-${var.eks_ng_name}"
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [for subnet in aws_subnet.private_subnets : subnet.id]

  ami_type       = "AL2023_x86_64_STANDARD"
  disk_size      = 20
  instance_types = [var.node_instance_type]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-eks-node-group"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_role_policy_1,
    aws_iam_role_policy_attachment.eks_node_role_policy_2,
    aws_iam_role_policy_attachment.eks_node_role_policy_3,
    aws_iam_role_policy_attachment.eks_node_role_policy_4,
  ]
}