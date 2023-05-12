resource "ovh_cloud_project_kube" "cluster" {
  service_name = var.ovh_public_cloud_project_id
  name         = var.k8s_cluster_name
  region       = var.k8s_cluster_region
  version      = var.k8s_cluster_version
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
