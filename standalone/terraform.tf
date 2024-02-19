terraform {
  backend "local" {}
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.26.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}

provider "kubectl" {
    config_path = "./kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "./kubeconfig"
  }
}

provider "kubernetes" {
    config_path = "./kubeconfig"
}

resource null_resource "ingress-nginx" {}