resource "aws_iam_role" "lbc_role" {
  name = "lbc_role"


    assume_role_policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "AllowEksAuthToAssumeRoleForPodIdentity",
              "Effect": "Allow",
              "Principal": {
                  "Service": "pods.eks.amazonaws.com"
              },
              "Action": [
                  "sts:AssumeRole",
                  "sts:TagSession"
              ]
          }
      ]
  })

}



resource "aws_iam_policy" "alb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for AWS Load Balancer Controller"
  policy      = file("iam_policy.json") 
}

resource "aws_iam_role_policy_attachment" "lbc-attach" {
  role       = aws_iam_role.lbc_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

resource "aws_eks_pod_identity_association" "eks_pod_identity_association" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-sa"
  role_arn        = aws_iam_role.lbc_role.arn
  depends_on = [helm_release.aws_load_balancer_controller]
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "eks-pod-identity-agent"
  addon_version            = "v1.3.2-eksbuild.2"  
  resolve_conflicts_on_create        = "OVERWRITE"
  
  depends_on = [aws_eks_node_group.eks_node_group]
}
