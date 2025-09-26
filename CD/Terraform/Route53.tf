resource "aws_route53_zone" "main" {
  name = "shebl22.me" 
  
  tags = {
    Name = "Main Domain Zone"
  }
}

output "route53_name_servers" {
  description = "Name servers for the Route53 hosted zone"
  value = aws_route53_zone.main.name_servers
}

