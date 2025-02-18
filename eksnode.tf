# EKS 마스터 노드 그룹
resource "aws_eks_node_group" "eks_ma_node" {
  cluster_name    = aws_eks_cluster.eks_clu.name
  node_group_name = "${var.name}-master-node"
  node_role_arn   = aws_iam_role.eks_noderole.arn
  subnet_ids      = concat(aws_subnet.eksnet_ma[*].id)
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types  = ["t3.micro"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# EKS 워커 노드 그룹
resource "aws_eks_node_group" "eks_work_node" {
  cluster_name    = aws_eks_cluster.eks_clu.name
  node_group_name = "${var.name}-worker-node"
  node_role_arn   = aws_iam_role.eks_noderole.arn
  subnet_ids      = concat(aws_subnet.eksnet_work[*].id)
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.eks_node_template.id
    version = aws_launch_template.eks_node_template.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# IAM 역할 생성
resource "aws_iam_role" "eks_noderole" {
  name = "eks-noderole"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# 기본 EKS 노드 정책들
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_noderole.name
  depends_on = [aws_iam_role.eks_noderole]
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_noderole.name
  depends_on = [aws_iam_role.eks_noderole]
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_noderole.name
  depends_on = [aws_iam_role.eks_noderole]
}

# 추가 노드 정책
resource "aws_iam_role_policy" "eks_node_policy" {
  name = "eks-node-policy"
  role = aws_iam_role.eks_noderole.name
  depends_on = [aws_iam_role.eks_noderole]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.eks_noderole.arn
      },
      {
        Effect   = "Allow"
        Action   = [
          "ec2:RunInstances",
          "ec2:DescribeInstances",
          "ec2:CreateLaunchTemplate",
          "ec2:DescribeLaunchTemplates"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "eks:CreateNodegroup",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      }
    ]
  })
}
