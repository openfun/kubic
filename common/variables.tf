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

variable "argocd_repo_url" {
  type        = string
  description = "ArgoCD applications repo URL"
}

variable "argocd_repo_username" {
  type        = string
  description = "ArgoCD applications repo username"
}

variable "argocd_repo_password" {
  type        = string
  description = "ArgoCD applications repo password"
}

variable "argocd_avp_version" {
  type        = string
  description = "ArgoCD argo-vault-plugin version"
  default     = "1.14.0"
}

variable "letsencrypt_email" {
  type        = string
  description = "Email address to use for the clusterIssuer"
}

variable "cluster_issuer_server" {
  type        = string
  description = "Server to use for the clusterIssuer"
}

variable "issuers" {
  type = list(object({
    name                    = string
    email                   = string
    server                  = string
    private_key_secret_name = string
  }))
  description = "List of issuers to create"
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

variable "vault_server_hostname" {
  type        = string
  description = "The hostname to use for the Vault server ingress"
  default     = ""
}

variable "install-hashicorp-vault" {
  type        = bool
  description = "Install Hashicorp Vault"
}

variable "vault_leader_tls_servername" {
  type        = string
  description = "The servername to use for the TLS certificate"
  default     = null
}

variable "vault_data_storage_size" {
  type        = string
  description = "The size, in Gi, of the data storage volume"
  default     = "10"
}

variable "vault_api_signed_certificate" {
  type        = string
  description = "The name of the signed certificate secret in Secrets Manager"
  default     = null
  sensitive   = true
}

variable "vault_api_private_key" {
  type        = string
  description = "The name of the certificate private key secret in Secrets Manager"
  default     = null
  sensitive   = true
}

variable "vault_api_ca_bundle" {
  type        = string
  description = "The name of the CA bundle secret in Secrets Manager"
  default     = null
  sensitive   = true
}

variable "vault_kms_seal_config" {
  type        = map(string)
  description = "A map containing the seal configuration information"
  default     = null
}

variable "vault_ui" {
  type        = bool
  description = "Enable the Vault UI"
  default     = false
}

variable "kubernetes_vault_ui_service_type" {
  type        = string
  description = "The Kubernetes service type to use for the Vault UI"
  default     = "ClusterIP"
}

variable "vault_seal_method" {
  type        = string
  description = "The Vault seal method to use"
  default     = "shamir"
}
