resource "kubernetes_manifest" "openproject_ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "openproject-ingress"
      namespace = kubernetes_namespace.openproject.metadata[0].name
      annotations = {
        "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
        "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
        # Optional additional useful annotations
        "nginx.ingress.kubernetes.io/proxy-body-size"    = "10m"
        "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      }
    }
    spec = {
      ingressClassName = "nginx"
      rules = [{
        host = var.hostname
        http = {
          paths = [{
            path     = "/"
            pathType = "Prefix"
            backend = {
              service = {
                name = "openproject"
                port = {
                  number = 8080
                }
              }
            }
          }]
        }
      }]
      tls = [{
        hosts      = [var.hostname]
        secretName = "openproject-tls-secret"
      }]
    }
  }
}
