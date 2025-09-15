resource "kubernetes_config_map" "backend" {
  metadata {
    name      = "cm-back"
    namespace = "backend"
  }

  data = {
    FLASK_ENV     = "production"
    CORS_ORIGINS  = "http://${aws_lb.ALB.dns_name}"
  }
}
