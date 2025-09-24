resource "aws_eks_cluster" "eks" {
  name = "eks-cluster"
  version  = "1.31"
  role_arn = aws_iam_role.eks_role.arn

    vpc_config {
        endpoint_private_access = false 
        endpoint_public_access = true
    subnet_ids = [
      aws_subnet.private1.id,
      aws_subnet.private2.id,
      aws_subnet.public1.id
    ]
    security_group_ids = [aws_security_group.eks_control_plane.id]
  }
  
  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
    
  }



  depends_on = [ aws_iam_role_policy_attachment.eks-attach1, aws_iam_role_policy_attachment.eks-attach2]
}
