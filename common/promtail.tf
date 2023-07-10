resource "helm_release" "promtail" {
  name             = "promtail"
  namespace        = "promtail"
  create_namespace = true

  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = var.promtail_version

  values = [templatefile("${path.module}/promtail-values.yml", {})]
}
