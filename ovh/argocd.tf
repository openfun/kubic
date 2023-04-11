resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    # add any custom values for the Helm chart here
  ]
}