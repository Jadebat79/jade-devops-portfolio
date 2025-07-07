# Create monitoring namespace
resource "kubernetes_namespace" "openproject" {
  metadata {
    name = "openproject"
  }
}
