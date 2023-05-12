resource "ovh_cloud_project_kube_nodepool" "pool" {
  service_name   = var.ovh_public_cloud_project_id
  kube_id        = ovh_cloud_project_kube.cluster.id
  name           = var.k8s_nodepool_name
  flavor_name    = var.k8s_nodepool_flavor
  monthly_billed = var.k8s_nodepool_monthly_billed
  min_nodes      = var.k8s_nodepool_min_nodes
  max_nodes      = var.k8s_nodepool_max_nodes
  autoscale      = true

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
