data "aws_eks_addon_version" "vpc_cni_version" {
  addon_name         = "vpc-cni"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "vpc-cni"
  addon_version = data.aws_eks_addon_version.vpc_cni_version.version
  tags = merge(
    local.common_tags
  )
}

data "aws_eks_addon_version" "kube_proxy_version" {
  addon_name         = "kube-proxy"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "kube-proxy"
  addon_version = data.aws_eks_addon_version.kube_proxy_version.version
  tags = merge(
    local.common_tags
  )
}

data "aws_eks_addon_version" "coredns_version" {
  addon_name         = "coredns"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "coredns"
  addon_version = data.aws_eks_addon_version.coredns_version.version
  tags = merge(
    local.common_tags
  )

  depends_on = [aws_eks_node_group.eks_node_group]
}

data "aws_eks_addon_version" "eks_pod_identity_agent_version" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.eks_pod_identity_agent_version.version
  tags = merge(
    local.common_tags
  )
}

