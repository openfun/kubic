resource "ovh_cloud_project_kube" "cluster" {
  service_name = var.ovh_public_cloud_project_id
  name         = var.k8s_cluster_name
  region       = var.k8s_cluster_region
  version      = var.k8s_cluster_version
}

resource "ovh_cloud_project_kube_nodepool" "pool" {
  service_name   = var.ovh_public_cloud_project_id
  kube_id        = ovh_cloud_project_kube.cluster.id
  name           = var.k8s_nodepool_name
  flavor_name    = var.k8s_nodepool_flavor
  monthly_billed = var.k8s_nodepool_monthly_billed
  min_nodes      = var.k8s_nodepool_min_nodes
  max_nodes      = var.k8s_nodepool_max_nodes
  desired_nodes  = var.k8s_nodepool_desired_nodes
  autoscale      = var.k8s_nodepool_autoscale

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

output "kubeconfig" {
  value       = ovh_cloud_project_kube.cluster.kubeconfig
  description = "The kubeconfig to access the cluster"
  sensitive   = true
}

output "nodesurl" {
  description = "The URL to access the cluster nodes"
  value       = ovh_cloud_project_kube.cluster.nodes_url
}

output "url" {
  value       = ovh_cloud_project_kube.cluster.url
  description = "The URL to access the cluster"
}
