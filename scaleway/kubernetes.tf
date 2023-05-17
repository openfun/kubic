resource "scaleway_k8s_cluster" "k8s_cluster" {
  name                        = var.k8s_cluster_name
  version                     = var.k8s_cluster_version
  cni                         = "cilium"
  delete_additional_resources = true
}

resource "scaleway_k8s_pool" "k8s_pool" {
  cluster_id = scaleway_k8s_cluster.k8s_cluster.id
  name       = var.k8s_nodepool_name
  node_type  = var.k8s_nodepool_flavor
  size       = var.k8s_nodepool_size
}

resource "null_resource" "kubeconfig" {
  depends_on = [scaleway_k8s_pool.k8s_pool] # at least one pool here
  triggers = {
    host                   = scaleway_k8s_cluster.k8s_cluster.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.k8s_cluster.kubeconfig[0].token
    cluster_ca_certificate = scaleway_k8s_cluster.k8s_cluster.kubeconfig[0].cluster_ca_certificate
  }
}

output "kubeconfig" {
  value       = scaleway_k8s_cluster.k8s_cluster.kubeconfig[0].config_file
  description = "kubeconfig for kubectl access."
  sensitive   = true
}