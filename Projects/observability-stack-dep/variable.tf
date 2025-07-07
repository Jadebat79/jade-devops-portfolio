variable "grafana_domain" {
  type        = string
  description = "Preconfigured Grafana A record"
}

variable "storage_class" {
  type        = string
  default     = "hcloud-volumes"
  description = "Hetzner storage class name"
}

variable "grafana_admin_password" {
  type        = string
  sensitive   = true
  description = "Grafana admin password"
}

variable "region" {
  type        = string
  description = "AWS region"
}