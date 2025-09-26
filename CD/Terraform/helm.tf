# resource "helm_release" "aws_load_balancer_controller" {
#   depends_on = [aws_eks_node_group.eks_node_group]
#   name       = "aws-load-balancer-controller"
#   namespace = "kube-system"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   version    = "1.8.1"

#     set{
#       name  = "serviceAccount.name"
#       value = "lbc-sa"
#     }
#      set {
#       name  = "serviceAccount.create"
#       value = "true"
#     }

#     set {
#     name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.lbc.arn
#   }
#       set {
#     name  = "region"
#     value = "us-east-1"
#   }

#     set {
#     name  = "vpcId"
#     value = aws_vpc.main.id
#   }



#    set {
#       name  = "clusterName"
#       value = aws_eks_cluster.eks.name
#     }



# }


resource "helm_release" "argo" {
  depends_on = [aws_eks_node_group.eks_node_group]
  disable_openapi_validation = true

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
  depends_on = [helm_release.argo]
  disable_openapi_validation = true
  name       = "argocd-apps"
  namespace  = "argocd"
  create_namespace = true
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"

  values = [
    templatefile("${path.module}/values/argocd-apps-values.tpl",{
      lbc_role_arn = aws_iam_role.lbc.arn
      edns_role_arn = aws_iam_role.edns.arn
      ebs_role_arn = aws_iam_role.ebs.arn
      eso_role_arn = aws_iam_role.eso.arn
      cluster_name = aws_eks_cluster.eks.name
      vpc_id       = aws_vpc.main.id 
      aws_region   = var.region 
    })
  ]
}

# resource "helm_release" "external-secrets" {
#   depends_on = [aws_eks_node_group.eks_node_group]
#   name       = "external-secrets"
#   namespace  = "eso"
#   repository = "https://charts.external-secrets.io"
#   chart      = "external-secrets"

#   set {
#     name = "serviceAccount.create"
#     value = "true"
#   }
#   set {
#     name = "serviceAccount.name"
#     value = "eso-sa"
#   }
#    set {
#     name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.eso.arn
#   }
# }




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
