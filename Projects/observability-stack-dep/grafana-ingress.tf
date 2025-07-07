resource "kubernetes_manifest" "grafana_ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "grafana-ingress"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      annotations = {
        "cert-manager.io/cluster-issuer"                = "letsencrypt-prod"
        "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
        # Optional additional useful annotations
        "nginx.ingress.kubernetes.io/proxy-body-size"    = "10m"
        "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      }
    }
    spec = {
      ingressClassName = "nginx"
      rules = [{
        host = var.grafana_domain
        http = {
          paths = [{
            path     = "/"
            pathType = "Prefix"
            backend = {
              service = {
                name = "kube-prometheus-stack-grafana"
                port = {
                  number = 3000
                }
              }
            }
          }]
        }
      }]
      tls = [{
        hosts      = [var.grafana_domain]
        secretName = "grafana-tls-secret"
      }]
    }
  }
}