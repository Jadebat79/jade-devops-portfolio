resource "kubernetes_ingress_v1" "airbyte_ingress" {
  metadata {
    name      = "${var.airbyte_namespace}-ingress"
    namespace = kubernetes_namespace.airbyte.metadata[0].name

    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target"          = "/"
      "cert-manager.io/cluster-issuer"                      = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/force-ssl-redirect"      = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size"         = "500m"
      "nginx.ingress.kubernetes.io/proxy-buffer-size"       = "16k"
      "nginx.ingress.kubernetes.io/proxy-buffers-number"    = "8"
      "nginx.ingress.kubernetes.io/proxy-busy-buffers-size" = "32k"
    }
  }

  spec {
    ingress_class_name = var.ingress_class

    rule {
      host = var.ingress_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "${helm_release.airbyte.name}-webapp-svc"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = [var.ingress_host]
      secret_name = "airbyte-tls-secret"
    }
  }

  depends_on = [
    helm_release.airbyte
  ]
}

