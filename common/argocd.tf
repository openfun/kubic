resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [
    templatefile("${path.module}/argocd-values.yaml.tftpl",
      {
        host_name           = var.argocd_hostname
        password            = var.argocd_password
        cluster_issuer_name = var.cluster_issuer_name
        repo_url            = var.argocd_repo_url
        repo_username       = var.argocd_repo_username
        repo_password       = var.argocd_repo_password
        avp_version         = var.argocd_avp_version
        vault_addr          = var.vault_server_hostname
      }
    )
  ]

}

resource "helm_release" "argocd-apps" {
  name = "argocd-apps"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"

  values = [
    templatefile("${path.module}/argocd-apps-values.yaml.tftpl",
      {
        repo_url = var.argocd_repo_url
      }
    )
  ]

}
