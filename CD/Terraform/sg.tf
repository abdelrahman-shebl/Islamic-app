resource "aws_security_group" "instance_SG" {
  vpc_id      = aws_vpc.main.id

   ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ALB_SG.id]
  }

  # ingress {
  #   from_port       = 443
  #   to_port         = 443
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.ALB_SG.id]
  # }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.JS_SG.id]
  }

   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

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

resource "aws_security_group" "ALB_SG" {
  vpc_id      = aws_vpc.main.id

   ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port       = 443
  #   to_port         = 443
  #   protocol        = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}