# output "JS_Public_IP" {
#   value = aws_instance.JS.public_ip
# }

output "ALB_DNS" {
  value = aws_lb.ALB.dns_name
}