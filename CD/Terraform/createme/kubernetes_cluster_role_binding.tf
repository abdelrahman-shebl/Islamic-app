resource "kubernetes_cluster_role_binding" "viewer_binding" {
  metadata {
    name = "viewer-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "Group"
    name      = "my-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}
