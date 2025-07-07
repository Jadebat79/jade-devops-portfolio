# resource "kubernetes_secret" "db_secret" {
#   metadata {
#     name      = "openproject-db-secret"
#     namespace = kubernetes_namespace.openproject.metadata[0].name
#   }
#   data = {
#     password = var.db_password
#   }
# }

# resource "kubernetes_secret" "s3_secret" {
#   metadata {
#     name      = "openproject-s3-secret"
#     namespace = kubernetes_namespace.openproject.metadata[0].name
#   }
#   data = {
#     access_key = var.s3_access_key
#     secret_key = var.s3_secret_key
#   }
# }

resource "random_password" "secret_key_base" {
  length  = 64
  special = false
}

# resource "kubernetes_secret" "rails_secret" {
#   metadata {
#     name      = "openproject-rails-secret"
#     namespace = kubernetes_namespace.openproject.metadata[0].name
#   }
#   data = {
#     "secret-key-base" = random_password.secret_key_base.result
#   }
# }
