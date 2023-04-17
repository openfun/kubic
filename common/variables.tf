variable "cluster_issuer_name" {
  type        = string
  description = "Name of the clusterIssuer"
  default     = "cert-manager-global"
}

variable "argocd_hostname" {
  type        = string
  description = "The hostname to use for the ArgoCD ingress"
}

variable "argocd_password" {
  type        = string
  description = "ArgoCD password hash, can be defined with `argocd account bcrypt --password change_me` after installing ArgoCD CLI"
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
  sensitive   = true
}

variable "install-hashicorp-vault" {
  type        = bool
  description = "Install Hashicorp Vault"
}
