terraform {
  backend "s3" {
  }
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.0.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.0"
    }
  }
  required_version = ">= 0.15"
}

provider "scaleway" {
  access_key = var.scaleway_access_key
  secret_key = var.scaleway_secret_key
  project_id = var.scaleway_project_id
  region     = var.scaleway_region
}

resource "scaleway_k8s_cluster" "joy" {
  name                        = "joy"
  version                     = "1.26.2"
  cni                         = "cilium"
  delete_additional_resources = true
}

resource "scaleway_k8s_pool" "john" {
  cluster_id = scaleway_k8s_cluster.joy.id
  name       = "john"
  node_type  = "DEV1-M"
  size       = 1
}

resource "null_resource" "kubeconfig" {
  depends_on = [scaleway_k8s_pool.john] # at least one pool here
  triggers = {
    host                   = scaleway_k8s_cluster.joy.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.joy.kubeconfig[0].token
    cluster_ca_certificate = scaleway_k8s_cluster.joy.kubeconfig[0].cluster_ca_certificate
  }
}

output "kube_config" {
  value       = scaleway_k8s_cluster.joy.kubeconfig[0].config_file
  description = "kubeconfig for kubectl access."
  sensitive   = true
}


provider "kubectl" {
  host  = null_resource.kubeconfig.triggers.host
  token = null_resource.kubeconfig.triggers.token
  cluster_ca_certificate = base64decode(
    null_resource.kubeconfig.triggers.cluster_ca_certificate
  )
  load_config_file = false
}

provider "helm" {
  kubernetes {
    host  = null_resource.kubeconfig.triggers.host
    token = null_resource.kubeconfig.triggers.token
    cluster_ca_certificate = base64decode(
      null_resource.kubeconfig.triggers.cluster_ca_certificate
    )
  }
}

provider "kubernetes" {
  host  = null_resource.kubeconfig.triggers.host
  token = null_resource.kubeconfig.triggers.token
  cluster_ca_certificate = base64decode(
    null_resource.kubeconfig.triggers.cluster_ca_certificate
  )
}
