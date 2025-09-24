# resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name = aws_eks_cluster.eks.name
#   addon_name   = "aws-ebs-csi-driver"
# }


# resource "kubernetes_storage_class" "gp2csi" {
#   metadata {
#     name = "gp2-csi"
#   }
#   storage_provisioner = "ebs.csi.aws.com"
#   volume_binding_mode = "WaitForFirstConsumer"
#   reclaim_policy      = "Delete"
#   allow_volume_expansion = "true"
#   parameters = {
#     type = "gp2"
#   }
# }