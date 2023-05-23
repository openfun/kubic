# Standalone use

If you already have a cluster (with another provider or whatever), you can still use this Terraform to deploy all the mentioned tools on it. For this, you will need a `kubeconfig` file to access your cluster. (or your credentials, if so, you will have to modify by yourself the `terraform.tf` file).

This part will install :
- Cert-manager, provisionned with issuers
- Prometheus along Grafana
- ArgoCD provisionned with a default repository
- Velero
- Hashicorp Vault

## Steps

Follow the following steps (every command must be run at the root of the repository):
- Run `bin/bootstrap.sh standalone` and fill the asked variables;
  - Only the most common variables are prompted, if you want to change other variables, you will have to edit the `standalone/terraform.tfvars` file by yourself. (the complete list of variables is available in the `standalone/variables.tf` file)
- Run `bin/terraform-init.sh standalone` to initialize the Terraform state;
- Put your `kubeconfig` file in the `standalone` folder;
- Run `bin/terraform-plan.sh standalone` to see what will be deployed;
- Run `bin/terraform-apply.sh standalone` to deploy.
