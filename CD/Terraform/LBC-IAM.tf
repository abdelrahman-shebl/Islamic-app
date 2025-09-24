data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "default" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}


resource "aws_iam_role" "lbc" {
  name = "lbc-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = aws_iam_openid_connect_provider.default.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.default.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:lbc-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lbc-policy" {
  name        = "lbc-policy"

  policy = file("policies/iam_lbc.json")
}


resource "aws_iam_role_policy_attachment" "lbc-attach" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc-policy.arn
}