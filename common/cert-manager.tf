resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.13.1"

  set {
    name  = "installCRDs"
    value = "true"
  }

}

resource "kubectl_manifest" "clusterissuer" {
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