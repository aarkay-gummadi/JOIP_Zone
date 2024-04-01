
resource "aws_vpc" "myvpc" {
  cidr_block       = var.aws_vpc
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "mysubnet1" {

  availability_zone = "{var.region}a"
  cidr_block        = var.cidr_block1
  vpc_id            = aws_vpc.myvpc.id

  tags = {
    Name = "mysubnet1"
  }
}

resource "aws_subnet" "mysubnet2" {

  availability_zone = "{var.region}b"
  cidr_block        = var.cidr_block2
  vpc_id            = aws_vpc.myvpc.id

  tags = {
    Name = "mysubnet2"
  }
}

resource "aws_iam_role" "myiam" {
  name = "aws_eks_cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_eks_cluster" "qtaarkay" {
  name     = "qtaarkay"
  role_arn = aws_iam_role.myiam.arn

  vpc_config {
    subnet_ids = [aws_subnet.mysubnet1.id, aws_subnet.mysubnet2.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.iam_policy_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.iam_policy_AmazonEKSVPCResourceController
  ]
}

resource "aws_iam_role_policy_attachment" "iam_policy_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.myiam.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "iam_policy_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.myiam.name
}


data "aws_availability_zones" "nodezones" {
  state = "available"
}

resource "aws_subnet" "nodesubnets" {
  count = 2

  availability_zone = data.aws_availability_zones.nodezones.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.myvpc.cidr_block, 8, count.index)
  vpc_id            = aws_vpc.myvpc.id

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.qtaarkay.name}" = "shared"
  }
}

resource "aws_eks_node_group" "mynode" {
  cluster_name    = aws_eks_cluster.qtaarkay.name
  node_group_name = "mynode"
  node_role_arn   = aws_iam_role.nodeiam.arn
  subnet_ids      = aws_subnet.nodesubnets[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.iam_policy_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.iam_policy_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.iam_policy_AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "nodeiam" {
  name = "eks-node-group-example"

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

resource "aws_iam_role_policy_attachment" "iam_policy_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodeiam.name
}

resource "aws_iam_role_policy_attachment" "iam_policy_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodeiam.name
}

resource "aws_iam_role_policy_attachment" "iam_policy_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodeiam.name
}