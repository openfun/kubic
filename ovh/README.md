# Create a pre-setup k8s cluster with OVHcloud

This Terraform aims at creating a k8s cluster setup with :

- NGINX Ingress Controller
- Cert-manager
- ArgoCD

# Deployment steps

## Create Terraform's state

First, we have to create an s3 bucket to store the Terraform's state, so that it can be available everywhere (and not only on your computer).

- Go to `/ovh/state_bucket`, and do a `terraform init`
- Provide the correct variables in a `.tfvars` file
- Create the bucket with a `terraform plan` followed by a `terraform apply`
- Save the provided `access_key` et `secret_key`

## Create and provision the cluster

Now we've got our s3 bucket, fill the `backend.conf.template` with the information you previously obtained. They are needed for Terraform to know in what state your cluster is or will be or has been.

Next :

- Provide the correct variables in a `.tfvars` file. 
- Do a `terraform init`, then `terraform plan` then `terraform apply` to create your cluster. 

