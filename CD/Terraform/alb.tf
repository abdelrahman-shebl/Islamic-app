# resource "aws_lb" "alb" {
#   name               = "alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.ALB_SG.id]
#   subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

# }

# resource "aws_lb_target_group" "http_TG" {
#   port        = 30080
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.main.id
#   target_type = "instance"

#   health_check {
#     protocol            = "HTTP"
#     port                = "30080"
#     path                = "/"            # or "/healthz" if ingress-nginx exposes it
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
# }

# # resource "aws_lb_target_group" "https_TG" {
# #   port     = 443
# #   protocol = "HTTPS"
# #   vpc_id   = aws_vpc.main.id
# #   target_type = "instance"
# # }


# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.http_TG.arn
#   }
# }

# # resource "aws_lb_listener" "https" {
# #   load_balancer_arn = aws_lb.ALB.arn
# #   port              = 443
# #   protocol          = "HTTPS"

# #   ssl_policy        = "ELBSecurityPolicy-2016-08"
# #   certificate_arn   = aws_acm_certificate.my_cert.arn

# #   default_action {
# #     type             = "forward"
# #     target_group_arn = aws_lb_target_group.https_TG.arn
# #   }
# # }

# resource "aws_lb_target_group_attachment" "ec2_http" {
#   target_group_arn = aws_lb_target_group.http_TG.arn
#   target_id        = aws_instance.instance.id
#   port             = 30080
# }

# # resource "aws_lb_target_group_attachment" "ec2_https" {
# #   target_group_arn = aws_lb_target_group.https_TG.arn
# #   target_id        = aws_instance.instance.id
# #   port             = 443
# # }
