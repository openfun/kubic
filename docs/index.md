# Kubic - Kubernetes Infrastructure as Code

[![Kubernetes](https://img.shields.io/static/v1?style=for-the-badge&message=Kubernetes&color=326CE5&logo=Kubernetes&logoColor=FFFFFF&label=)](https://kubernetes.io)
[![NGINX](https://img.shields.io/static/v1?style=for-the-badge&message=NGINX&color=009639&logo=NGINX&logoColor=FFFFFF&label=)](https://kubernetes.github.io/ingress-nginx/)
[![ArgoCD](https://img.shields.io/static/v1?style=for-the-badge&message=ArgoCD&color=EF7B4D&logo=Argo&logoColor=FFFFFF&label=)](https://argo-cd.readthedocs.io)
[![Vault](https://img.shields.io/static/v1?style=for-the-badge&message=Vault&color=000000&logo=Vault&logoColor=FFFFFF&label=)](https://www.vaultproject.io)
[![Terraform](https://img.shields.io/static/v1?style=for-the-badge&message=Terraform&color=7B42BC&logo=Terraform&logoColor=FFFFFF&label=)](https://www.terraform.io)

Available on:

[![Scaleway](https://img.shields.io/static/v1?style=for-the-badge&message=Scaleway&color=4F0599&logo=Scaleway&logoColor=FFFFFF&label=)](https://www.scaleway.com)
[![OVH](https://img.shields.io/static/v1?style=for-the-badge&message=OVH&color=123F6D&logo=OVH&logoColor=FFFFFF&label=)](https://www.ovh.com)

## Overview

Kubic is a cutting edge, ready for production and multi cloud provider Kubernetes infrastructure as code. It integates an ingress controller, a certificate manager, a monitoring stack, a GitOps tool with complete secret management and a backup tool.

This Terraform aims at creating a managed k8s cluster setup with :

- NGINX Ingress Controller
- Cert-manager
- Prometheus / Grafana
- ArgoCD
- Hashicorp Vault if needed
- ArgoCD Vault Plugin if Vault is deployed
- Velero for backuping the cluster
- Loki if enabled

The cluster can be deployed either on OVHCloud or on Scaleway. New provider can be added by creating a new folder in the root of the repository, and by following the same architecture as the existing providers.

## Repository architecture

```bash
.
├── docs                  # Folder containing the documentation
├── state_bucket          # Folder containing the Terraform to create a S3 bucket for the Terraform state
├── vault                 # Folder containing the Terraform to configure Hashicorp Vault
├── common                # Folder containing the Terraform which is common to all the providers
├── ovh                   # Folder declaring Terraform to deploy a cluster on OVHCloud
├── scaleway              # Folder declaring Terraform to deploy a cluster on Scaleway
├── examples              # Folder containing examples of applications to deploy with ArgoCD
├── .gitignore
├── LICENSE
└── README.md
```

All files contained in the folder `common` are symbolicaly linked in the folders `ovh` and `scaleway` to avoid code duplication.

## Getting started

- Create you cluster:
  - [Manual deployment](cluster-manual.md)
  - [Automatic deployment](cluster-auto.md)
- [Configure Hashicorp Vault](hashicorp-vault.md)
- [Configure ArgoCD](argocd.md)
- [Configure Velero](velero.md)
- [Standalone use](standalone.md)

## Contributing

Currently, only OVH and Scaleway are supported as providers. Here are the guidelines to add a new provider:

- Create a new folder in the root of the repository, with the name of the provider;
- Create a symlink for all files in `common` to your new folder;
- Create a `terraform.tf` file containing:
  - Terraform configuration with a `s3` backend;
  - The `helm`, `kubernetes` and `kubectl` providers along with the provider(s) you need, correctly configured;
- A `kubernetes.tf` file creating the cluster, with an output named `kubeconfig` that contains the actual kubeconfig for the cluster;
- A `ingress-nginx.tf` file, deploying the [ingress-nginx ingress controller](https://kubernetes.github.io/ingress-nginx) and configuring it with an external IP (you may need to create a load balancer on your provider). The ingress IP should be a Terraform output named `ingress_ip`;
  - This must also create a `null_resource` named `ingress-nginx` that will `depends_on` on the node pool of your cluster (this is to get a consistent dependency chain for Terraform)
  - The controller must have at least the following configuration:

```yaml
controller:
  metrics:
    enabled: true
    serviceMonitor:
      additionalLabels:
        release: prometheus
      enabled: true
  extraArgs:
    enable-ssl-passthrough: true
  admissionWebhooks:
    timeoutSeconds: 30
```

- Edit the `docker-compose.yaml` and create a service (adapt merely the code) for your provider.
