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

variable "argocd_version" {
  type        = string
  description = "The version of ArgoCD helm release to install"
  default     = "5.33.1"
}

variable "argocd_apps_version" {
  type        = string
  description = "ArgoCD apps version"
  default     = "1.6.2"
}

variable "argocd_avp_version" {
  type        = string
  description = "ArgoCD argo-vault-plugin version"
  default     = "1.14.0"
}

variable "main_cluster_issuer_name" {
  type        = string
  description = "Name of the clusterIssuer"
  default     = "letsencrypt-prod"
}

variable "issuers" {
  type = list(object({
    name                    = string
    email                   = string
    server                  = string
    private_key_secret_name = string
  }))
  description = "List of issuers to create"
  default = [
    {
      name                    = "letsencrypt-prod"
      server                  = "https://acme-v02.api.letsencrypt.org/directory"
      email                   = "admin@admin.fr",
      private_key_secret_name = "letsencrypt-prod"
      }, {
      name                    = "letsencrypt-staging"
      server                  = "https://acme-staging-v02.api.letsencrypt.org/directory"
      email                   = "admin@admin.fr"
      private_key_secret_name = "letsencrypt-staging"
    }
  ]
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

variable "grafana_persistence_enabled" {
  type        = bool
  description = "Enable Grafana persistence"
  default     = false
}

variable "grafana_persistence_size" {
  type        = string
  description = "Grafana persistence size"
  default     = "10Gi"
}

variable "prometheus_persistence_enabled" {
  type        = bool
  description = "Enable Prometheus persistence"
  default     = false
}

variable "prometheus_persistence_size" {
  type        = string
  description = "Prometheus persistence size"
  default     = "20Gi"
}

variable "vault_server_hostname" {
  type        = string
  description = "The hostname to use for the Vault server ingress"
  default     = ""
}

variable "install_hashicorp_vault" {
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
  description = "The signed certificate secret in Secrets Manager (not the filename)"
  default     = null
  sensitive   = true
}

variable "vault_api_private_key" {
  type        = string
  description = "The certificate private key secret in Secrets Manager (not the filename)"
  default     = null
  sensitive   = true
}

variable "vault_api_ca_bundle" {
  type        = string
  description = "The CA bundle secret in Secrets Manager (not the filename)"
  default     = null
  sensitive   = true
}

variable "vault_ui" {
  type        = bool
  description = "Enable the Vault UI"
  default     = true
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

variable "vault_version" {
  type        = string
  description = "The version of Hashicorp vault helm release to install"
  default     = "0.24.1"
}

variable "velero_version" {
  type        = string
  description = "The version of Velero to install"
  default     = "4.0.2"
}

variable "velero_s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for Velero backups"
}

variable "velero_s3_bucket_region" {
  type        = string
  description = "The region of the S3 bucket to use for Velero backups"
}

variable "velero_s3_bucket_endpoint" {
  type        = string
  description = "The endpoint of the S3 bucket to use for Velero backups"
  default     = "s3.amazonaws.com"
}

variable "velero_s3_access_key_id" {
  type        = string
  description = "The access key of the S3 bucket to use for Velero backups"
  sensitive   = true
}

variable "velero_s3_secret_access_key" {
  type        = string
  description = "The secret key of the S3 bucket to use for Velero backups"
  sensitive   = true
}

variable "velero_default_volumes_to_fs_backup" {
  type        = bool
  description = "Enable volume filesystem backups by default"
  default     = false
}

variable "promtail_version" {
  type        = string
  description = "The chart version of promtail to install"
  default     = "6.11.5"
}

variable "loki_enabled" {
  type        = bool
  description = "Enable the log aggregation with Loki"
  default     = false
}

variable "loki_version" {
  type        = string
  description = "The chart version of loki to install"
  default     = "5.8.9"
}

variable "loki_s3_chunks_bucket_name" {
  type        = string
  description = "The name of the S3 chunks bucket to use for loki"
}

variable "loki_s3_ruler_bucket_name" {
  type        = string
  description = "The name of the S3 ruler bucket to use for loki"
}

variable "loki_s3_admin_bucket_name" {
  type        = string
  description = "The name of the S3 admin bucket to use for loki"
}

variable "loki_s3_bucket_region" {
  type        = string
  description = "The region of the S3 bucket to use for loki"
}

variable "loki_s3_bucket_endpoint" {
  type        = string
  description = "The endpoint of the S3 bucket to use for loki"
  default     = "s3.amazonaws.com"
}

variable "loki_s3_access_key_id" {
  type        = string
  description = "The access key of the S3 bucket to use for loki"
  sensitive   = true
}

variable "loki_s3_secret_access_key" {
  type        = string
  description = "The secret key of the S3 bucket to use for loki"
  sensitive   = true
}
