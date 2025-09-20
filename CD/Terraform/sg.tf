# resource "aws_security_group" "cluster_SG" {
#   vpc_id      = aws_vpc.main.id

#     ingress {
#     from_port       = 30080
#     to_port         = 30080
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ALB_SG.id]
#   }
#    ingress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # ingress {
#   #   from_port       = 443
#   #   to_port         = 443
#   #   protocol        = "tcp"
#   #   security_groups = [aws_security_group.ALB_SG.id]
#   # }

#   ingress {
#     from_port       = 22
#     to_port         = 22
#     protocol        = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     # security_groups = [aws_security_group.JS_SG.id]
#   }

#    egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

# }

# resource "aws_security_group" "JS_SG" {
#   vpc_id      = aws_vpc.main.id


#   ingress {
#     from_port       = 22
#     to_port         = 22
#     protocol        = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#    egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

# }

# resource "aws_security_group" "ALB_SG" {
#   vpc_id      = aws_vpc.main.id

#    ingress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # ingress {
#   #   from_port       = 443
#   #   to_port         = 443
#   #   protocol        = "tcp"
#   #   cidr_blocks = ["0.0.0.0/0"]
#   # }

#    egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

# }

resource "aws_security_group" "eks_control_plane" {
  name        = "eks-control-plane-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for EKS control plane"

  ingress {
    description = "Allow kubectl/API access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eks_nodes" {
  name        = "eks-nodes-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for EKS worker nodes"

  ingress {
    description = "Allow control plane to nodes"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_control_plane.id]
  }

  ingress {
    description = "Allow node-to-node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow NodePort services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

