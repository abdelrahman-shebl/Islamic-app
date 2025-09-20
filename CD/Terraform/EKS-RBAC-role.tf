data "aws_caller_identity" "current" {}

# resource "aws_iam_role" "eks_admin" {


#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root/shebl22"
#         }
#       },
#     ]
#   })


# }


# resource "aws_iam_policy" "eks_admin" {
#   name = "AmazonEKSAdminPolicy"

#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": "eks:*",
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": "iam:PassRole",
#             "Resource": "*",
#             "Condition": {
#                 "StringEquals": {
#                     "iam:PassedToService": "eks.amazonaws.com"
#                 }
#             }
#         }
#     ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "eks-attach" {
#   role       = aws_iam_role.eks_admin.name
#   policy_arn = aws_iam_policy.eks_admin.arn
# }


# resource "aws_iam_policy" "eks-assume-policy" {

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "eks:*",
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#     ]
#   })
# }

# resource "aws_iam_policy" "eks_assume_admin" {
#   name = "AmazonEKSAssumeAdminPolicy"

#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": "sts:AssumeRole",
#             "Resource": "${aws_iam_role.eks_admin.arn}"
#         }
#     ]
# }
# POLICY
# }
# resource "aws_iam_user_policy_attachment" "admin_assume_role" {
#   user = shebl22
#   policy_arn = aws_iam_policy.eks_assume_admin.arn
# }

resource "aws_eks_access_entry" "example" {
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/shebl22"
  
  kubernetes_groups = ["my-admin"]
}