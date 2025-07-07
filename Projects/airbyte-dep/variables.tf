# Cluster & kubeconfig
variable "kubeconfig_path" {
  default = "~/.kube/config"
}

variable "kube_context" {
  default = ""
}

variable "airbyte_helm_version" {
  description = "Airbyte Helm chart version"
  type        = string
  default     = "1.7.1" # Pinned to latest version
}

variable "airbyte_namespace" {
  description = "Kubernetes namespace for Airbyte"
  type        = string
  default     = "airbyte"
}

variable "postgresql_host" {}
variable "postgresql_port" {}
variable "postgresql_database" {}
variable "postgresql_username" {}
variable "postgresql_password" {
  sensitive = true
}

variable "s3_bucket_name" {}
variable "s3_region" {}
variable "s3_access_key" {
  sensitive = true
}
variable "s3_secret_key" {
  sensitive = true
}

variable "ingress_host" {}
variable "ingress_class" {
  default = "nginx"
}

variable "storage_class_name" {}
variable "airbyte_workspace_size" {
  default = "20Gi"
}

variable "cert_manager_cluster_issuer" {
  type        = string
  description = "Cert-manager ClusterIssuer (empty for dev)"
  default     = ""
}
variable "tls_secret_name" {
  type        = string
  description = "TLS Secret name (empty for dev)"
  default     = ""
}

variable "pvc_name" {
  type = string
}

variable "environment" {
  description = "Deployment environment: dev | staging | prod"
  type        = string
}

# Ingress
variable "enable_ingress" {
  type        = bool
  description = "Enable creation of Ingress resource"
}

variable "airbyte_username" {}
variable "airbyte_password" {}
