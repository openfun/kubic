# Create a pre-setup k8s cluster with OVHcloud & ScaleWay

This Terraform aims at creating a k8s cluster setup with :

- NGINX Ingress Controller
- Cert-manager
- ArgoCD

The cluster can be deployed either on OVHCloud or on Scaleway.

# Deployment steps

## Create Terraform's state

First, we have to create an s3 bucket to store the Terraform's state, so that it can be available everywhere (and not only on your computer).

- Go to `/state_bucket`, and do a `terraform init`
- Provide the correct variables in a `.tfvars` file
- Create the bucket with a `terraform plan` followed by a `terraform apply`
- Save the provided `access_key` et `secret_key`

**There is no need to create two buckets, unless you explicitly want to do so. Both states can be stored in the same bucket** 

## Create and provision the cluster

*Put yourself in the folder corresponding to the provider you want*

Now we've got our s3 bucket, fill the `backend.conf.template` with the information you previously obtained. They are needed for Terraform to know in what state your cluster is or will be or has been.

Next :

- Provide the correct variables in a `.tfvars` file.
- Copy the `credentials.auto.tfvars.json.template` to `credentials.auto.tfvars.json` and fill it with the corresponding credentials
- Do a `terraform init`, then `terraform plan` then `terraform apply` to create your cluster. 

