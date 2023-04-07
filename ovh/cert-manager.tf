
# Install cert-manager with Helm, to be able to create TLS certificates
# with Let's encrypt

# resource "helm_release" "cert-manager" {
#   name             = "cert-manager"
#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"
#   namespace        = "cert-manager"
#   create_namespace = true

#   set {
#     name  = "installCRDs"
#     value = true
#   }
# }

module "cert_manager" {
  source  = "terraform-iaac/cert-manager/kubernetes"
  version = "2.5.0"

  cluster_issuer_email  = "admin@mysite.com"
  cluster_issuer_server = "https://acme-staging-v02.api.letsencrypt.org/directory"
  namespace_name        = "cert-manager"
  create_namespace      = true
}
