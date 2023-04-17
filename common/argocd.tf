resource "helm_release" "argocd" {
  name       = "argocd-release"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo/argo-cd"

  values = [
    "${templatefile("argocd-values.yaml", {hostName = "argocd.scw-mano.fun-plus.fr", password = "$2a$10$mRtiB9CLUR723Q.8oCM7A.BLSsikNOzag8O1y6s.pgVUTT1W2jSf2"})}"
  ]
}
