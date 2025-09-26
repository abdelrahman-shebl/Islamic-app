
resource "aws_iam_role" "edns" {
  name = "edns-role"

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
            "${replace(aws_iam_openid_connect_provider.default.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:edns-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "edns-policy" {
  name        = "edns-policy"

  policy = file("policies/iam_eso.json")
}


resource "aws_iam_role_policy_attachment" "edns-attach" {
  role       = aws_iam_role.edns.name
  policy_arn = aws_iam_policy.edns-policy.arn
}