# [AUTOMATIC] Deployment steps

_Every command must be run at the root of the repository_

## Create Terraform's state

First, we need a s3 bucket to store the Terraform's state, so that it can be available everywhere (and not only on your computer). If you already have a bucket, you can skip this step.

This repository provides a Terraform to create a bucket on OVH. For this step, you will need OVH API credentials (`application key`, `secret key` and `consumer key`, as well as the project id in which you will create the bucket, see [here if you do not know how to get them](https://help.ovhcloud.com/csm/en-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042777#advanced-usage-pair-ovhcloud-apis-with-an-application)).

- Execute the corresponding script : `bin/init-bucket.sh`, after entering all the required information, it will create a bucket on OVH;
- Save the provided credentials `access_key`, `secret_key` and `bucket_name`, you will need them for the next step.

## Create and provision the cluster

### Configure the backend

Now we've got our s3 bucket, we have to setup Terraform's backend, where it stores its state. For this, we will use the s3 bucket we just created (or the one you already have).

Run `bin/bootstrap-backend.sh <your provider>` to create the backend. It will create a `backend.conf` file, which will be used by Terraform to store its state in the s3 bucket. Replace `<your provider>` either with `ovh` or `scaleway`.

If you used the previous script to generate the bucket, here are some information you need :

- Region : `gra`
- Endpoint : `https://s3.gra.io.cloud.ovh.net/`
- Skip region validation : `true`
- Skip credentials validation : `true`

### Provide the correct information

Terraform needs a few variables to create your cluster, please run `bin/bootstrap.sh <your-provider>` and provide the desired values for each parameter. You will need :

- The hostname for several services : ArgoCD, Grafana, Vault (if installed)
- A S3 bucket for Velero
- ArgoCD needs a Git repository with HTTPS credentials for access. You can use a private repository, or a public one. If you use a private repository, you will need to provide the HTTPS credentials (username and password). If you use a public repository, you can leave the username and password empty.
- API keys for your provider:
  - For OVH, see [here](https://help.ovhcloud.com/csm/en-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042777#advanced-usage-pair-ovhcloud-apis-with-an-application)
  - For Scaleway, see [here](https://www.scaleway.com/en/docs/identity-and-access-management/iam/how-to/create-api-keys/)

**The script will prompt for the most common variables. By default, some variables are not prompted (and their default value is then used). If you wish, you can look into the `variables.tf` and the `variables-common.tf` files to see all the variables that can be set. Simply add them to the `terraform.tfvars` file.**

### Deploy the cluster

After your `terraform.tfvars` file has been successfully created, you can now deploy the cluster. Run `bin/terraform-init.sh <your provider>` to initialize Terraform. After this, run `bin/terraform-plan.sh <your provider>`, the output shows you what Terraform will do. If you are satisfied with the plan, run `bin/terraform-apply.sh <your provider>` to deploy the cluster. _(Please ignore the output of the command beginning with 'To perform exactly these actions...')_

While running, the `terraform-apply.sh` script may crash (especially with OVH). If so, analyze the error. If it is related to timeouts or server errors, simply re-run the script. (if you encounter errors re-running `terraform-apply.sh`, try running `terraform-plan.sh` before). The script may last more than 10 minutes, please be patient.

**Warning: If the script were to crash, make sure Terraform has not been creating ressources (e.g. a k8s cluster) in the background (which has not been linked to the state due to the crash). If so, you will have to delete them manually.**

At the end of the script, please make the needed changes on your DNS (adding the ingress IP to the needed domains), you may be able to retrieve your Kubeconfig file with the following command: `bin/get-kube-config.sh <your provider>`.

### Destroy the cluster

With: `bin/terraform-destroy <your provider>`. **Warning: there is no confirmation, it will destroy the cluster immediately.**

Next step → [Configure Hashicorp Vault](./hashicorp-vault.md)
