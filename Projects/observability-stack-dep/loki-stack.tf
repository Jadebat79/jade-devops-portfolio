resource "helm_release" "loki_stack" {
  name       = "loki-stack"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = "2.10.2" # Check for latest version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    templatefile("${path.module}/values/loki-stack.yaml", {
      storage_class = var.storage_class
    })
  ]

  set {
    name  = "loki.image.tag"
    value = "2.9.4"
  }

  set {
    name  = "promtail.image.tag"
    value = "3.2.1"
  }

  depends_on = [helm_release.prometheus_stack]
}