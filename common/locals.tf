locals {
  generate_tls_certs = (var.install_hashicorp_vault && (var.vault_api_ca_bundle == null || var.vault_api_signed_certificate == null || var.vault_api_private_key == null)) ? true : false
}
