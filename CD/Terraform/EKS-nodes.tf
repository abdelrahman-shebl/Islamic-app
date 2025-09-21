resource "aws_iam_role" "ec2_role" {


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "EKSWorkerNodePolicy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "EKS_CNI_Policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "ECR_ReadOnly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
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
  instance_types = ["t2.micro"]

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
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