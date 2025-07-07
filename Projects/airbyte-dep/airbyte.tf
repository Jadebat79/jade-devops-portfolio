# Airbyte Helm Release
resource "helm_release" "airbyte" {
  name       = "airbyte"
  repository = "https://airbytehq.github.io/helm-charts"
  chart      = "airbyte"
  version    = var.airbyte_helm_version
  namespace  = kubernetes_namespace.airbyte.metadata[0].name
  wait       = true
  timeout    = 3000

  # Helm values as a dynamic map

  values = [
    yamlencode({
      global = {
        database = {
          type              = "external"
          secretName        = kubernetes_secret.postgresql.metadata[0].name
          host              = var.postgresql_host
          port              = var.postgresql_port
          database          = var.postgresql_database
          user              = var.postgresql_username
          passwordSecretKey = "password"
        }

        storage = {
          type = "s3"
          s3 = {
            bucket = var.s3_bucket_name
            region = var.s3_region
            accessKeyIdSecretRef = {
              secret = kubernetes_secret.s3.metadata[0].name
              key    = "accesskey"
            }
            secretAccessKeySecretRef = {
              secret = kubernetes_secret.s3.metadata[0].name
              key    = "secretkey"
            }
          }
        }

        workspace = {
          storageClass = var.storage_class_name
          storageSize  = var.airbyte_workspace_size
        }

        auth = {
          enabled = true
          instanceAdmin = {
            firstName         = "Admin"
            lastName          = "User"
            email             = "jaynaj79@gmail.com"
            secretName        = "airbyte-auth-secret"
            passwordSecretKey = "AIRBYTE_PASSWORD"
            emailSecretKey    = "AIRBYTE_USERNAME" # Using username field for email
          }
        }
        airbyteUrl = "https://${var.ingress_host}"
      }

      # Disable Keycloak
      keycloak = {
        enabled = false
      }

      # Disable embedded components
      postgresql = {
        enabled = false
      }

      minio = {
        enabled = false
      }

      # Disable built-in Ingress
      webapp = {
        ingress = {
          enabled = false
        }
      }
    })
  ]
}
