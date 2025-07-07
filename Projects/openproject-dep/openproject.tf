resource "helm_release" "openproject" {
  name       = "openproject"
  namespace  = kubernetes_namespace.openproject.metadata[0].name
  repository = "https://charts.openproject.org"
  chart      = "openproject"
  version    = "10.0.0"
  timeout    = 1200 # 20 minutes

  # Base values file
  values = [
    file("${path.module}/values/openproject.yaml")
  ]

  # Dynamic settings
  set {
    name  = "persistence.size"
    value = var.storage_size
  }

  set {
    name  = "persistence.storageClassName"
    value = var.storage_class
  }

  set {
    name  = "openproject.host"
    value = var.hostname
  }

  # Database configuration
  set {
    name  = "postgresql.connection.host"
    value = var.db_host
  }

  set {
    name  = "postgresql.connection.port"
    value = "5432"
  }

  set {
    name  = "postgresql.auth.username"
    value = var.db_user
  }

  set {
    name  = "postgresql.auth.database"
    value = var.db_name
  }

  set_sensitive {
    name  = "postgresql.auth.password"
    value = var.db_password
  }

  # S3 configuration
  set {
    name  = "s3.region"
    value = var.s3_region
  }

  set {
    name  = "s3.bucketName"
    value = var.s3_bucket
  }

  set_sensitive {
    name  = "s3.auth.accessKeyId"
    value = var.s3_access_key
  }

  set_sensitive {
    name  = "s3.auth.secretAccessKey"
    value = var.s3_secret_key
  }

  # Rails secret
  set_sensitive {
    name  = "openproject.secretKeyBase"
    value = random_password.secret_key_base.result
  }

  # SMTP configuration (example)
  set {
    name  = "openproject.email.deliveryMethod"
    value = "smtp"
  }

  set {
    name  = "openproject.email.smtpAddress"
    value = var.smtp_host
  }

  set {
    name  = "openproject.email.smtpUserName"
    value = var.smtp_user
  }

  set_sensitive {
    name  = "openproject.email.smtpPassword"
    value = var.smtp_password
  }

  set {
    name  = "openproject.email.smtpEnableStarttlsAuto"
    value = "true"
  }

  set {
    name  = "openproject.email.smtpAuthentication"
    value = "login"
  }

  set {
    name  = "openproject.email.emailFrom"
    value = var.smtp_from
  }

  set {
    name  = "openproject.email.smtpPort"
    value = var.smtp_port
  }



  # Additional overrides via CLI
  dynamic "set" {
    for_each = var.extra_helm_settings
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}
