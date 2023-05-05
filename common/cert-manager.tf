module "cert_manager" {
  count   = 0
  source  = "terraform-iaac/cert-manager/kubernetes"
  version = "2.5.0"

  cluster_issuer_email                   = var.letsencrypt_email
  cluster_issuer_name                    = var.main_cluster_issuer_name
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
  cluster_issuer_server                  = var.cluster_issuer_server
  namespace_name                         = "cert-manager"
  create_namespace                       = true

  depends_on = [
    null_resource.ingress-nginx
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.11.1"

  set {
    name  = "installCRDs"
    value = "true"
  }

}

resource "kubectl_manifest" "clusterissuer_letsencrypt_prod" {
  for_each = { for issuer in var.issuers : issuer.name => issuer }
  provider = kubectl
  yaml_body = templatefile("issuer.yml.tftpl", {
    name                    = each.value.name
    email                   = each.value.email
    server                  = each.value.server
    private_key_secret_name = each.value.private_key_secret_name
  })

  depends_on = [
    helm_release.cert_manager
  ]
}