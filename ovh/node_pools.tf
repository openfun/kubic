resource "ovh_cloud_project_kube_nodepool" "pool" {
  service_name   = var.service_name
  kube_id        = ovh_cloud_project_kube.cluster.id
  name           = "default-pool"
  flavor_name    = "d2-4" # 2 vCPU, 4 GB RAM, à ajuster au besoin
  autoscale      = true
  monthly_billed = false
  min_nodes      = 1
  max_nodes      = 10
}