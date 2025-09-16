resource "kubernetes_config_map" "backend" {
    depends_on = [null_resource.wait_for_kubeconfig]
  metadata {
    name      = "cm-back"
  }

  data = {
    FLASK_ENV     = "production"
    CORS_ORIGINS  = "http://${aws_lb.ALB.dns_name}"
  }
}
