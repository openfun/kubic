resource "helm_release" "kube-prometheus" {
  name             = "kube-prometheus-stack"
  namespace        = "prometheus"
  create_namespace = true

  version    = "45.9.1"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [templatefile("${path.module}/grafana-values.yml", {
    hostname = "grafana.scw-tf.fun-plus.fr"
    issuer   = var.cluster_issuer_name
  })]
}
