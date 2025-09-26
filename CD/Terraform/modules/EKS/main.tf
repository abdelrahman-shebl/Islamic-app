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



resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "general"
  node_role_arn   = aws_iam_role.ec2_role.arn
  subnet_ids      = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
    ]
  remote_access {
    ec2_ssh_key = aws_key_pair.mykey.key_name
    source_security_group_ids = [aws_security_group.eks_nodes.id]
  }

  capacity_type = "ON_DEMAND"
  instance_types = ["t2.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }
  labels = {
    role = "general" 
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.EKS_CNI_Policy,
    aws_iam_role_policy_attachment.EKSWorkerNodePolicy,
  ]
  
}
