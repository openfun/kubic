resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.k8s_ingress_nginx_version

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}