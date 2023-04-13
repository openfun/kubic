resource "helm_release" "hashicorp-vault" {
  count            = var.install-hashicorp-vault ? 1 : 0
  name             = "hashicorp-vault"
  namespace        = "hashicorp-vault"
  create_namespace = true

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"

  values = [templatefile("${path.module}/vault-values.yml", {
    kubernetes_secret_name_tls_ca    = kubernetes_secret.tls_ca.metadata.0.name
    kubernetes_secret_name_tls_cert  = kubernetes_secret.tls.metadata.0.name
    kubernetes_vault_ui_service_type = var.kubernetes_vault_ui_service_type

    vault_data_storage_size     = var.vault_data_storage_size
    vault_leader_tls_servername = var.vault_leader_tls_servername
    vault_leader_tls_servername = var.vault_leader_tls_servername
    vault_seal_method           = var.vault_seal_method
    vault_ui                    = var.vault_ui
  })]
}
