resource "helm_release" "hashicorp-vault" {
  count            = var.install-hashicorp-vault ? 1 : 0
  name             = "hashicorp-vault"
  namespace        = "hashicorp-vault"
  create_namespace = true

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"

  values = [templatefile("${path.module}/vault-values.yml", {})]
}
