resource "helm_release" "loki" {
  name             = "loki"
  namespace        = "loki"
  create_namespace = true
  count = var.loki_enabled ? 1 : 0

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = var.loki_version

  values = [templatefile("${path.module}/loki-values.yml", {
    loki_s3_chunks_bucket_name = var.loki_s3_chunks_bucket_name
    loki_s3_ruler_bucket_name  = var.loki_s3_ruler_bucket_name
    loki_s3_admin_bucket_name  = var.loki_s3_admin_bucket_name
    loki_s3_bucket_region      = var.loki_s3_bucket_region
    loki_s3_bucket_endpoint    = var.loki_s3_bucket_endpoint
    loki_s3_access_key_id      = var.loki_s3_access_key_id
    loki_s3_secret_access_key  = var.loki_s3_secret_access_key
  })]
}
