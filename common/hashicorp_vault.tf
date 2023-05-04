resource "kubernetes_namespace" "hashicorp-vault" {
  count = (var.install-hashicorp-vault) ? 1 : 0
  metadata {
    name = "hashicorp-vault"
  }

  depends_on = [
    null_resource.ingress-nginx
  ]
}

resource "helm_release" "hashicorp-vault" {
  count     = (var.install-hashicorp-vault) ? 1 : 0
  name      = "hashicorp-vault"
  namespace = "hashicorp-vault"

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

    cluster_issuer_name         = var.cluster_issuer_name
    vault_server_hostname       = var.vault_server_hostname
    enable_vault_server_ingress = var.vault_server_hostname != "" ? true : false
  })]

  depends_on = [
    kubernetes_namespace.hashicorp-vault
  ]
}
