output "instance_Public_IP" {
  value = aws_instance.instance.public_ip
}

output "ALB_DNS" {
  value = aws_lb.ALB.dns_name
}