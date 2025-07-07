variable "environment" {}
variable "db_host" {}
variable "db_user" {}
variable "db_name" {}
variable "db_password" {
  sensitive = true
}
variable "s3_bucket" {}
variable "s3_region" {}
variable "s3_access_key" {
  sensitive = true
}
variable "s3_secret_key" {
  sensitive = true
}
variable "hostname" {}
variable "storage_size" {}
variable "storage_class" {}
variable "smtp_host" {}
variable "smtp_user" {
  default = ""
}
variable "smtp_password" {
  sensitive = true
  default   = ""
}
variable "smtp_port" {
  default = 587
}

variable "smtp_from" {
  default = "openproject@openproject.meshstaging.com"
}
variable "extra_helm_settings" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
