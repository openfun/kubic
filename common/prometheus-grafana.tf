resource "helm_release" "kube-prometheus" {
  name             = "kube-prometheus-stack"
  namespace        = "prometheus"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [templatefile("${path.module}/prom-grafana-values.yml", {
    hostname = var.grafana_hostname
    issuer   = var.cluster_issuer_name
    grafana_admin_password = var.grafana_admin_password
  })]
}
