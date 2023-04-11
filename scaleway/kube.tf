terraform {
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

provider "kubectl" {
  host  = null_resource.kubeconfig.triggers.host
  token = null_resource.kubeconfig.triggers.token
  cluster_ca_certificate = base64decode(
    null_resource.kubeconfig.triggers.cluster_ca_certificate
  )
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

module "cert_manager" {
  source = "terraform-iaac/cert-manager/kubernetes"

  cluster_issuer_email                   = var.letsencrypt_email
  cluster_issuer_name                    = var.cluster_issuer_name
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
  namespace_name                         = "cert-manager"
  cluster_issuer_server                  = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

resource "scaleway_lb_ip" "nginx_ip" {
  zone       = "fr-par-1"
  project_id = scaleway_k8s_cluster.joy.project_id
}

output "ingress_ip" {
  value       = scaleway_lb_ip.nginx_ip.ip_address
  description = "Adress of the loadbalancer"
  sensitive   = true
}

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  namespace        = "nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name  = "controller.service.loadBalancerIP"
    value = scaleway_lb_ip.nginx_ip.ip_address
  }

  // enable proxy protocol to get client ip addr instead of loadbalancer one
  set {
    name  = "controller.config.use-proxy-protocol"
    value = "true"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/scw-loadbalancer-proxy-protocol-v2"
    value = "true"
  }

  // indicates in which zone to create the loadbalancer
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/scw-loadbalancer-zone"
    value = scaleway_lb_ip.nginx_ip.zone
  }

  // enable to avoid node forwarding
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  // enable this annotation to use cert-manager
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/scw-loadbalancer-use-hostname"
    value = "true"
  }
}

resource "helm_release" "kube-prometheus" {
  name             = "kube-prometheus-stack"
  namespace        = "prometheus"
  create_namespace = true

  version    = "45.9.1"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [templatefile("${path.module}/values.yml", {
    hostname = "grafana.scw-tf.fun-plus.fr"
    issuer   = var.cluster_issuer_name
  })]
}
