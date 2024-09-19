data "aws_iam_policy_document" "eks_cluster_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "eks_cluster_policy_1" {
  name = "AmazonEKSClusterPolicy"
}

data "aws_iam_policy" "eks_cluster_policy_2" {
  name = "AmazonEKSVPCResourceController"
}

resource "aws_iam_role" "eks_cluster_service_role" {
  name               = "${var.project_name}-${var.eks_cluster_service_role_name}"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_trust_policy.json
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-eks-cluster-service-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_1" {
  role       = aws_iam_role.eks_cluster_service_role.name
  policy_arn = data.aws_iam_policy.eks_cluster_policy_1.arn
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_2" {
  role       = aws_iam_role.eks_cluster_service_role.name
  policy_arn = data.aws_iam_policy.eks_cluster_policy_2.arn
}

data "aws_iam_policy_document" "eks_node_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "eks_node_policy_1" {
  name = "AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "eks_node_policy_2" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "eks_node_policy_3" {
  name = "AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "eks_node_policy_4" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "eks_node_role" {
  name               = "${var.project_name}-${var.eks_node_role_name}"
  assume_role_policy = data.aws_iam_policy_document.eks_node_trust_policy.json
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-eks-node-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_node_role_policy_1" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = data.aws_iam_policy.eks_node_policy_1.arn
}

resource "aws_iam_role_policy_attachment" "eks_node_role_policy_2" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = data.aws_iam_policy.eks_node_policy_2.arn
}

resource "aws_iam_role_policy_attachment" "eks_node_role_policy_3" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = data.aws_iam_policy.eks_node_policy_3.arn
}

resource "aws_iam_role_policy_attachment" "eks_node_role_policy_4" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = data.aws_iam_policy.eks_node_policy_4.arn
}

resource "aws_eks_access_entry" "eks_acces_entry_1" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.caller_identity.account_id}:root"
}

resource "aws_eks_access_policy_association" "eks_access_policy_association_1" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.caller_identity.account_id}:root"

  access_scope {
    type = "cluster"
  }
}