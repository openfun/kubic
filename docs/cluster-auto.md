# Deployment steps
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
