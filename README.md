# SharedKube

## Overview 

This Terraform aims at creating a managed k8s cluster setup with :

- NGINX Ingress Controller
- Cert-manager
- ArgoCD
- Prometheus / Grafana
- Velero for backuping the cluster
- Hashicorp Vault if needed

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
  - [Manual deployment](docs/cluster-manual.md)
  - [Automatic deployment](docs/cluster-auto.md)
- [Configure HashicorpVault](docs/hashicorp-vault.md)
- [Configure ArgoCD](docs/argocd.md)

