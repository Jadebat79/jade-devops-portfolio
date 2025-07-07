resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "69.3.0" # Check for latest version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    templatefile("${path.module}/values/prom-stack.yaml", {
      storage_class    = var.storage_class
      grafana_password = var.grafana_admin_password
      grafana_domain   = var.grafana_domain
    })
  ]
}