resource "helm_release" "argocd" {
  name             = "argocd-release"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [
    templatefile("${path.module}/argocd-values.yaml.tftpl",
      {
        hostName            = var.argocd_hostname
        password            = var.argocd_password
        cluster_issuer_name = var.cluster_issuer_name
      }
    )
  ]

}
