data "aws_eks_cluster" "eks-data" {
  name = aws_eks_cluster.eks.name
}

data "aws_caller_identity" "current" {}


locals {
  oidc_issuer_url = data.aws_eks_cluster.eks-data.identity[0].oidc[0].issuer
  oidc_provider   = replace(local.oidc_issuer_url,"https://", "")

}
resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0ecd4e0e3"]
}

# data "aws_iam_openid_connect_provider" "eks" {
#   arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider}"
# }



resource "aws_iam_role" "eso" {

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Condition = {
            StringEquals = {
                "${local.oidc_provider}:sub" = "system:serviceaccount:eso:eso"
                "${local.oidc_provider}:aud" = "sts.amazonaws.com"
            }
        }
      },
    ]
  })


}



resource "aws_iam_policy" "eso" {
  name        = "EDNSpolicy"
  policy      = file("eso-policy.json") 

}


resource "aws_iam_role_policy_attachment" "eso" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso.arn
}

resource "kubernetes_namespace" "eso" {
  metadata {
    name = "eso"
  }
}


resource "kubernetes_service_account" "eso" {
  metadata {
    name = "eso"
    namespace = kubernetes_namespace.eso.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eso.arn
    }
  }
}

# resource "null_resource" "wait_for_eso_crds" {
#   depends_on = [helm_release.external-secrets]

#   provisioner "local-exec" {
#     command = <<EOT
    
#     until kubectl get crd secretstores.external-secrets.io &> /dev/null; do
#       echo "waiting for secretstores CRD..."
#       sleep 1
#     done

#     until kubectl get crd externalsecrets.external-secrets.io &> /dev/null; do
#       echo "waiting for externalsecrets CRD..."
#       sleep 1
#     done

#     EOT
#   }
# }


resource "helm_release" "external-secrets" {
  depends_on = [aws_eks_node_group.eks_node_group]
  name       = "external-secrets"
  namespace  = "eso"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"

  set {
    name = "serviceAccount.create"
    value = "false"
  }
  set {
    name = "serviceAccount.name"
    value = "eso"
  }
}

resource "null_resource" "wait_for_eso_crds" {
  depends_on = [helm_release.external-secrets]

  provisioner "local-exec" {
    command = <<EOT
    echo "[INFO] Waiting for ESO CRDs to be ready..."

    # wait for SecretStore CRD
    until kubectl get crd secretstores.external-secrets.io &> /dev/null; do
      echo "waiting for secretstores CRD..."
      sleep 2
    done

    # wait for ExternalSecret CRD
    until kubectl get crd externalsecrets.external-secrets.io &> /dev/null; do
      echo "waiting for externalsecrets CRD..."
      sleep 2
    done

    echo "[INFO] Applying ESO manifests..."
    kubectl apply -f eso/aws-secretstore.yaml
    kubectl apply -f eso/db-external-secret.yaml
    kubectl apply -f eso/backend-external-secret.yaml
    echo "[SUCCESS] ESO manifests applied!"
    EOT
  }
}



# resource "kubernetes_manifest" "aws_secret_store" {
#   depends_on = [null_resource.wait_for_eso_crds, kubernetes_namespace.eso]
#   manifest = {
#     apiVersion = "external-secrets.io/v1beta1"
#     kind       = "SecretStore"

#     metadata = {
#       name = "aws-secrets"
#       namespace = "eso"
#     }

#     spec = {
#         provider = {
#           aws = {
#             service = "ParameterStore"
#             region = "us-east-1"
#             auth = {
#               jwt = {
#                 serviceAccountRef = {
#                   name = "eso"
#                 }
#               }
#             }
#           }
#         }
#     }
#   }
# }

# resource "kubernetes_manifest" "DBCreds" {
#   depends_on = [null_resource.wait_for_eso_crds]
#   manifest = {
#     apiVersion = "external-secrets.io/v1beta1"
#     kind       = "ExternalSecret"

#     metadata = {
#       name      = "db-secrets-mapping"
#       namespace = "islamic-app"
#     }

#     spec = {
#       refreshInterval = "15m"
#       secretStoreRef = {
#         name = "aws-secrets"   
        
#         kind = "SecretStore"
#       }
#       target = {
#         name           = "db-secrets"
#         creationPolicy = "Owner"
#         type           = "Opaque"
#       }
#       data = [
#         {
#           secretKey = "POSTGRES_DB"
#           remoteRef = {
#             key      = "/myapp/database/creds"   
            
#             property = "POSTGRES_DB"             
            
#           }
#         },
#         {
#           secretKey = "POSTGRES_USER"
#           remoteRef = {
#             key      = "/myapp/database/creds"
#             property = "POSTGRES_USER"
#           }
#         },
#         {
#           secretKey = "POSTGRES_PASSWORD"
#           remoteRef = {
#             key      = "/myapp/database/creds"
#             property = "POSTGRES_PASSWORD"
#           }
#         },
#         {
#           secretKey = "POSTGRES_HOST_AUTH_METHOD"
#           remoteRef = {
#             key      = "/myapp/database/creds"
#             property = "POSTGRES_HOST_AUTH_METHOD"
#           }
#         }
#       ]
#     }
#   }
# }


# resource "kubernetes_manifest" "BackCreds" {
#   depends_on = [null_resource.wait_for_eso_crds]
#   manifest = {
#     apiVersion = "external-secrets.io/v1beta1"
#     kind       = "ExternalSecret"

#     metadata = {
#       name      = "back-secrets-mapping"
#       namespace = "islamic-app"
#     }

#     spec = {
#       refreshInterval = "15m"
#       secretStoreRef = {
#         name = "aws-secrets"   
#         kind = "SecretStore"
#       }
#       target = {
#         name           = "back-secrets"
#         creationPolicy = "Owner"
#         type           = "Opaque"
#       }
#       data = [
#         {
#           secretKey = "DATABASE_URL"
#           remoteRef = {
#             key      = "/myapp/back/creds"
#             property = "DATABASE_URL"
#           }
#         },
#         {
#           secretKey = "SECRET_KEY"
#           remoteRef = {
#             key      = "/myapp/back/creds"
#             property = "SECRET_KEY"
#           }
#         },
#         {
#           secretKey = "JWT_SECRET_KEY"
#           remoteRef = {
#             key      = "/myapp/back/creds"
#             property = "JWT_SECRET_KEY"
#           }
#         }
#       ]
#     }
#   }
# }
