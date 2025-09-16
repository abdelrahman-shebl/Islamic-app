resource "kubernetes_ingress_v1" "ingress" {
  depends_on = [null_resource.wait_for_kubeconfig]
  metadata {
    name = "ingress"
  }

  spec {

    rule {
      host = aws_lb.ALB.dns_name
      http {
        path {
          backend {
            service {
              name = "front-svc"
              port {
                number = 3000
              }
            }
          }
          path_type = "Prefix"
          path = "/"
        }

      }
    }
    
  }
}
