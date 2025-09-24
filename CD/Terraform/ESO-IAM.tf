
resource "aws_iam_role" "eso" {
  name = "eso-role"

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
            "${replace(aws_iam_openid_connect_provider.default.url, "https://", "")}:sub" = "system:serviceaccount:eso:eso-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eso-policy" {
  name        = "eso-policy"

  policy = file("policies/iam_eso.json")
}


resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso-policy.arn
}