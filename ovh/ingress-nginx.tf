resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.serviceMonitor.additionalLabels.release"
    value = "prometheus"
  }

  set {
    name  = "controller.extraArgs.enable-ssl-passthrough"
    value = "true"
  }
  depends_on = [
    helm_release.kube-prometheus,
    helm_release.cert_manager
  ]
}

data "kubernetes_service" "ingress-svc" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.ingress-nginx.namespace
  }
  depends_on = [
    helm_release.ingress-nginx
  ]
}

output "ingress_ip" {
  value       = data.kubernetes_service.ingress-svc.status.0.load_balancer.0.ingress.0.ip
  description = "Address of the loadbalancer"
}

resource "null_resource" "ingress-nginx" {
  depends_on = [
    ovh_cloud_project_kube_nodepool.pool
  ]
}

