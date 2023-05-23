# [MANUAL] Deployment steps

_This assumes you have the Terraform CLI installed on your computer._
## Create Terraform's state

First, we need a s3 bucket to store the Terraform's state, so that it can be available everywhere (and not only on your computer). If you already have a bucket, you can skip this step.

This repository provides a Terraform to create a bucket on OVH. For this step, you will need OVH API credentials (`application key`, `secret key` and `consumer key`, as well as the project id in which you will create the bucket, see [here if you do not know how to get them](https://help.ovhcloud.com/csm/en-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042777#advanced-usage-pair-ovhcloud-apis-with-an-application)).

- Go to `/state_bucket`, and do a `terraform init`
- Copy the `terraform.tfvars.template` into `terraform.tfvars` and provide the correct variables in it. (description of the vars is available in the `variables.tf` file)
- At this step, we need to do a tiny trick coming from [OVH](https://github.com/yomovh/tf-at-ovhcloud/blob/main/s3_bucket_only/README.md) :

_If you have AWS CLI already configured, you are good to go !_

_Else, due to a limitation in Terraform dependency graph for providers initialization (see this long lasting issue) it is required to have the following environement variables defined (even if they are dummy one and overridden during the script execution) : AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY_

_If they are not already defined you can use the following:_

```bash
export AWS_ACCESS_KEY_ID="no_need_to_define_an_access_key"
export AWS_SECRET_ACCESS_KEY="no_need_to_define_a_secret_key"
```

- Then create the bucket with a `terraform plan` followed by a `terraform apply`
- Save the provided `access_key` et `secret_key` (because the `secret_key` is a secret, you need to use the `terraform output secret_key` command to get it)

## Create and provision the cluster

_Put yourself in the folder corresponding to the provider you want_

Now we've got our s3 bucket, copy the `backend.conf.template` in a `backend.conf` file and fill it with the information you previously obtained. You may choose a name for your state file (using the `key` field). They are needed for Terraform to know in what state your cluster is or will be or has been.

Next :

- Provide the correct variables in a `terraform.tfvars` file. List of variables is available in the `variables.tf` file and in the `variables-common.tf` file, along with description and default values;
  - For Hashicorp Vault: if you do not have a custom certificate, just leave the following variables empty: `vault_api_signed_certificate`, `vault_api_private_key`, `vault_api_ca_bundle`.
  - You will need API credentials for the provider you choose:
    - For OVH, see [here](https://help.ovhcloud.com/csm/en-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042777#advanced-usage-pair-ovhcloud-apis-with-an-application)
    - For Scaleway, see [here](https://www.scaleway.com/en/docs/identity-and-access-management/iam/how-to/create-api-keys/)
- Do a `terraform init -backend-config=backend.conf`, then `terraform plan` then `terraform apply` to create your cluster. Doing so, your Terraform state will be saved in the s3 bucket.

_Using the OVH provider, you may encounter timeouts, or other errors. (coming from OVH) If so, simply re-run the `terraform apply` command. It will continue where it stopped and will eventually complete._

Next step → [Scripted cluster creation](./cluster-auto.md)