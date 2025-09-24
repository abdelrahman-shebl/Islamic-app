# data "aws_eks_cluster" "eks-data" {
#   name = aws_eks_cluster.eks.name
# }

# data "aws_caller_identity" "current" {}

# locals {
#   oidc_issuer_url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
#   oidc_provider   = replace(local.oidc_issuer_url,"https://", "")

# }

# data "aws_iam_openid_connect_provider" "eks" {
#   arn = "arn:aws:iam::${data.aws_caller_identity.current}:oidc-provider/${local.oidc_provider}"
# }


# resource "aws_iam_role" "externaldns" {

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Federated = data.aws_iam_openid_connect_provider.eks.arn
#         }
#         condtion = {
#             StringEquals = {
#                 "${local.oidc_provider}:sub" = "system:serviceaccount:${kubernetes_namespace.externaldns.metadata[0].name}:${kubernetes_service_account.externaldns.metadata[0].name}"
#                 "${local.oidc_provider}:aud" = "sts.amazonaws.com"
#             }
#         }
#       },
#     ]
#   })


# }


# resource "aws_iam_policy" "EDNSpolicy" {
#   name        = "EDNSpolicy"
#   policy      = file("ExternalDNS-policy.json") 

# }


# resource "aws_iam_role_policy_attachment" "externaldns" {
#   role       = aws_iam_role.externaldns.name
#   policy_arn = aws_iam_policy.EDNSpolicy.arn
# }

# resource "kubernetes_namespace" "externaldns" {
#   metadata {
#     name = "external-dns"
#   }
# }


# resource "kubernetes_service_account" "externaldns" {
#   metadata {
#     name = "external-dns"
#     namespace = kubernetes_namespace.externaldns.metadata[0].name
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.externaldns.arn
#     }
#   }
# }


# resource "helm_release" "aws_load_balancer_controller" {
#   depends_on = [aws_eks_node_group.eks_node_group]
#   name       = "external-dns"
#   namespace = kubernetes_namespace.externaldns.metadata[0].name
#   repository = "https://kubernetes-sigs.github.io/external-dns/"
#   chart      = "external-dns"

#      set {
#       name  = "provider"
#       value = "aws"
#     }
#       set {
#     name  = "AWS_DEFAULT_REGION"
#     value = "us-east-1"
#   }

#     set {
#     name  = "vpcId"
#     value = aws_vpc.main.id
#   }

#     set {
#     name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.lbc_role.arn
#   }

#    set {
#       name  = "clusterName"
#       value = aws_eks_cluster.eks.name
#     }
#     set{
#       name  = "serviceAccount.name"
#       value = "aws-load-balancer-sa"
#     }


# }
