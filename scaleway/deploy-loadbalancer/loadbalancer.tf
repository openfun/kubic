terraform {
  backend "s3" {
  }
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.16.0"
    }
  }
}

provider "scaleway" {
  access_key = var.scaleway_access_key
  secret_key = var.scaleway_secret_key
  project_id = var.scaleway_project_id
  region     = var.scaleway_region
}

resource "scaleway_lb_ip" "lb_ip" {
  zone       = "fr-par-1"
  project_id = var.scaleway_project_id
}

output "lb_ip" {
  value       = scaleway_lb_ip.lb_ip.ip_address
  description = "Address of the loadbalancer"
  sensitive   = true
}

output "lb_ip_zone" {
  value       = scaleway_lb_ip.lb_ip.zone
  description = "Address of the loadbalancer"
  sensitive   = true
}