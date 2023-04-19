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
