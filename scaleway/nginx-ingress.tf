
resource "scaleway_lb_ip" "nginx_ip" {
  zone       = "fr-par-1"
  project_id = scaleway_k8s_cluster.k8s_cluster.project_id
}

output "ingress_ip" {
  value       = scaleway_lb_ip.nginx_ip.ip_address
  description = "Address of the loadbalancer"
  sensitive   = true
}

resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  namespace        = "nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  values = [templatefile("${path.module}/nginx-values.yml", {
    zone      = scaleway_lb_ip.nginx_ip.zone
    ip_adress = scaleway_lb_ip.nginx_ip.ip_address
  })]

  depends_on = [
    scaleway_k8s_pool.k8s_pool
  ]
}

resource "null_resource" "ingress-nginx" {
  depends_on = [
    scaleway_k8s_pool.k8s_pool
  ]
}