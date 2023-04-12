module "cert_manager" {
  source  = "terraform-iaac/cert-manager/kubernetes"
  version = "2.5.0"

  cluster_issuer_email                   = var.letsencrypt_email
  cluster_issuer_name                    = var.cluster_issuer_name
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
  cluster_issuer_server                  = "https://acme-staging-v02.api.letsencrypt.org/directory"
  namespace_name                         = "cert-manager"
  create_namespace                       = true
}
