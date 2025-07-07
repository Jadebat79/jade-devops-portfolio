resource "kubernetes_namespace" "airbyte" {
  metadata {
    name = var.airbyte_namespace
  }
}
