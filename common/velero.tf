resource "helm_release" "velero" {
  name             = "velero"
  namespace        = "velero"
  create_namespace = true

  repository       = "https://vmware-tanzu.github.io/helm-charts"
  chart            = "velero"
  version          = var.velero_version
  timeout = 600

  values = [templatefile("${path.module}/velero-values.yml", {
    velero_s3_bucket_name       = var.velero_s3_bucket_name
    velero_s3_bucket_region     = var.velero_s3_bucket_region
    velero_s3_bucket_endpoint   = var.velero_s3_bucket_endpoint
    velero_s3_access_key_id     = var.velero_s3_access_key_id
    velero_s3_secret_access_key = var.velero_s3_secret_access_key
  })]
}