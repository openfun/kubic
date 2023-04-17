variable "cluster_issuer_name" {
  type        = string
  description = "Name of the clusterIssuer"
  default     = "cert-manager-global"
}

variable "letsencrypt_email" {
  type        = string
  description = "Email address to use for the clusterIssuer"
}

variable "grafana_hostname" {
  type        = string
  description = "The hostname to use for the Grafana ingress"
}

variable "grafana_admin_password" {
  type        = string
  description = "The password of the Grafana UI"
}