terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.15.0"
    }
  }
}

provider "vault" {
  address = var.vault_url
  token   = var.vault_root_token
}

# Enable the kv secret engine to store key/value secrets
resource "vault_mount" "kvv2" {
  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "example" {
  mount                = vault_mount.kvv2.path
  max_versions         = 5
  delete_version_after = 12600
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_role" "vault_backend" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "argocd"
  bound_service_account_names      = ["argocd-repo-server"]
  bound_service_account_namespaces = ["argocd"]
  token_ttl                        = 3600
  token_policies                   = ["argocd"]
}

resource "vault_policy" "vault_policy" {
  name = "argocd"

  policy = <<EOT
path "kv/*" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_config" "vault_backend_config" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = var.kubernetes_api_url
}
