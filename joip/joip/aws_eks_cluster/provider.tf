terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = aws_eks_cluster.qtaarkay.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.qtaarkay.certificate_authority[0].data)
}

