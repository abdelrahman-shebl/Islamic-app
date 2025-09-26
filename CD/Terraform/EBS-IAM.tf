
resource "aws_iam_role" "ebs" {
  name = "ebs-role"

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
            "${replace(aws_iam_openid_connect_provider.default.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-sa"
          }
        }
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "ebs-attach" {
  role       = aws_iam_role.ebs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

