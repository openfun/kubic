resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  namespace        = "nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  values = [templatefile("${path.module}/nginx-values.yml", {
    zone      = var.lb_ip_zone
    ip_adress = var.lb_ip
  })]

}
