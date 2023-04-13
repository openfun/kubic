#------------------------------------------------------------------------------
# Certificate Authority
#------------------------------------------------------------------------------
resource "tls_private_key" "ca" {
  count = local.generate_tls_certs ? 1 : 0

  algorithm   = "RSA"
  ecdsa_curve = "P384"
  rsa_bits    = "2048"
}

resource "tls_self_signed_cert" "ca" {
  count = local.generate_tls_certs ? 1 : 0

  #key_algorithm         = tls_private_key.ca[0].algorithm
  private_key_pem       = tls_private_key.ca[0].private_key_pem
  is_ca_certificate     = true
  validity_period_hours = "168"

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature"
  ]

  subject {
    organization = "HashiCorp (NonTrusted)"
    common_name  = "HashiCorp (NonTrusted) Private Certificate Authority"
    country      = "CA"
  }
}

#------------------------------------------------------------------------------
# Certificate
#------------------------------------------------------------------------------
resource "tls_private_key" "vault_private_key" {
  count = local.generate_tls_certs ? 1 : 0

  algorithm   = "RSA"
  ecdsa_curve = "P384"
  rsa_bits    = "2048"
}

resource "tls_cert_request" "vault_cert_request" {
  count = local.generate_tls_certs ? 1 : 0

  #key_algorithm   = tls_private_key.vault_private_key[0].algorithm
  private_key_pem = tls_private_key.vault_private_key[0].private_key_pem

  dns_names = [for i in range(3) : format("hashicorp-vault-%s.hashicorp-vault-internal", i)]

  subject {
    common_name  = "HashiCorp Vault Certificate"
    organization = "HashiCorp Vault Certificate"
  }
}

resource "tls_locally_signed_cert" "vault_signed_certificate" {
  count = local.generate_tls_certs ? 1 : 0

  cert_request_pem = tls_cert_request.vault_cert_request[0].cert_request_pem
  #ca_key_algorithm   = tls_private_key.ca[0].algorithm
  ca_private_key_pem = tls_private_key.ca[0].private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca[0].cert_pem

  validity_period_hours = "168"

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
}

resource "kubernetes_secret" "tls" {
  metadata {
    name      = "tls"
    namespace = "hashicorp-vault"
  }

  data = {
    "tls.crt" = local.generate_tls_certs ? tls_locally_signed_cert.vault_signed_certificate[0].cert_pem : var.vault_api_signed_certificate
    "tls.key" = local.generate_tls_certs ? tls_private_key.vault_private_key[0].private_key_pem : var.vault_api_private_key
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "tls_ca" {
  metadata {
    name      = "tls-ca"
    namespace = "hashicorp-vault"
  }

  data = {
    "ca.crt" = local.generate_tls_certs ? tls_self_signed_cert.ca[0].cert_pem : var.vault_api_ca_bundle
  }
}