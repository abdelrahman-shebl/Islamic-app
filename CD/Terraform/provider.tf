terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
     kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
      helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}


data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
    kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}



resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [aws_eks_node_group.eks_node_group]
  name       = "aws-load-balancer-controller"
  namespace = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.8.1"

    set {
      name  = "serviceAccount.create"
      value = "true"
    }
      set {
    name  = "region"
    value = "us-east-1"
  }

  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }
   set {
      name  = "clusterName"
      value = aws_eks_cluster.eks.name
    }
    set{
      name  = "serviceAccount.name"
      value = "aws-load-balancer-sa"
    }


}

# resource "helm_release" "sealed-secrets" {
#   name       = "sealed-secrets"
#   namespace  = "kube-system"
#   repository = "https://bitnami-labs.github.io/sealed-secrets"
#   chart      = "sealed-secrets"
#   # version    = "19.0.0"

#   values = [
#     file("${path.module}/sealed-secrets-key.yaml")
#   ]
# }

# resource "helm_release" "prometheus" {
#   name       = "my-kube-prometheus-stack"
#   namespace  = "monitoring"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"

#   values = [
#     file("${path.module}/prom-values.yaml")
#   ]
# }

resource "helm_release" "argo" {
  depends_on = [aws_eks_node_group.eks_node_group]
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  create_namespace = true

  values = [
    file("${path.module}/values/argo-values.yaml")
  ]
}

resource "helm_release" "argocd-apps" {
  depends_on = [aws_eks_node_group.eks_node_group, helm_release.argo]
  name       = "argocd-apps"
  namespace  = "argocd"
  create_namespace = true
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"

  values = [
    file("${path.module}/values/argocd-apps-values.yaml")
  ]
}