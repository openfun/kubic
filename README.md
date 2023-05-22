# Create a pre-setup k8s cluster with OVHcloud & ScaleWay

This Terraform aims at creating a k8s cluster setup with :

- NGINX Ingress Controller
- Cert-manager
- ArgoCD

The cluster can be deployed either on OVHCloud or on Scaleway.

# Deployment steps

## Create Terraform's state

First, we need a s3 bucket to store the Terraform's state, so that it can be available everywhere (and not only on your computer). If you already have a bucket, you can skip this step.

This repository provides a Terraform to create a bucket on OVH. 

- Go to `/state_bucket`, and do a `terraform init`
- Provide the correct variables in a `terraform.tfvars` file. (the needed variables are listed in the `variables.tf` file)
- At this step, we need to do a tiny trick coming from [OVH](https://github.com/yomovh/tf-at-ovhcloud/blob/main/s3_bucket_only/README.md) : 

*If you have AWS CLI already configured, you are good to go !*

*Else, due to a limitation in Terraform dependency graph for providers initialization (see this long lasting issue) it is required to have the following environement variables defined (even if they are dummy one and overridden during the script execution) : AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY*

*If they are not already defined you can use the following:*

```bash
export AWS_ACCESS_KEY_ID="no_need_to_define_an_access_key"  
export AWS_SECRET_ACCESS_KEY="no_need_to_define_a_secret_key"
```
- Then create the bucket with a `terraform plan` followed by a `terraform apply`
- Save the provided `access_key` et `secret_key` (because the `secret_key` is a secret, you need to use the `terraform output secret_key` command to get it)

## Create and provision the cluster

*Put yourself in the folder corresponding to the provider you want*

Now we've got our s3 bucket, copy the `backend.conf.template` in a `backend.conf` file and fill it with the information you previously obtained. You may choose a name for your state file (using the `key` field). They are needed for Terraform to know in what state your cluster is or will be or has been.

Next :

- Provide the correct variables in a `terraform.tfvars` file. List of variables is available in the `variables.tf` file and in the `variables-common.tf` file, along with description and default values;
  * For Hashicorp Vault: if you do not have a custom certificate, just leave the following variables empty: `vault_api_signed_certificate`, `vault_api_private_key`, `vault_api_ca_bundle`.
- Copy the `credentials.auto.tfvars.json.template` to `credentials.auto.tfvars.json` and fill it with the corresponding credentials (you need to create API keys from your providers). Terraform will automaticaly generate a certificate and use it for the vault;
  * For OVH, see [here](https://help.ovhcloud.com/csm/en-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042777#advanced-usage-pair-ovhcloud-apis-with-an-application)
  * For Scaleway, see [here](https://www.scaleway.com/en/docs/identity-and-access-management/iam/how-to/create-api-keys/)
- Do a `terraform init -backend-config=backend.conf`, then `terraform plan` then `terraform apply` to create your cluster. Doing so, your Terraform state will be saved in the s3 bucket.

*Using the OVH provider, you may encounter timeouts, or other errors. (coming from OVH) If so, simply re-run the `terraform apply` command. It will continue where it stopped and will eventually complete.*

## Hashicorp Vault

Once the cluster has been setup, Hashicorp Vault (now referred to as "vault") is not ready for use. It has to be initialized and to be unsealed. *Secrets will be handled in the following steps.*
To ensure HA on the cluster, the deployment consists of 3 pods, spread on 3 nodes. (the node autoscaling feature is used here). More pods can be created by modifying Terraform's vars. (HPA is not available though). 

*To perform the following steps, you need to have every pod in the `Running` state. You can check this with `kubectl get pods -n hashicorp-vault`. (they won't be marked as ready however)*

### Manual initialization
**Initialization of the vault**

Shamir's algorithm is used to encrypt the vault. *n* keys (with *n* > 0) are generated, and *m* keys (with 0 < *m* <= *n*) are needed to unseal the vault. This is achieved with the following command (using `kubectl` in the `hashicorp-vault` namespace):

```bash
kubectl exec hashicorp-vault-0 -- vault operator init \
    -key-shares=n \
    -key-threshold=m \
    -format=json > cluster-keys.json
```

This command generates a `cluster-keys.json` file containing :
* the *n* generated keys
* a root token, used to authenticate to the vault (once unsealed)

*If you read the doc, you might want to make the pods join the Raft cluster. The vault is here configured to join the Raft cluster by itself, so no action is required from the user here.*

**Unsealing of the vault**

The vault is still not available. Each pod must be *unsealed* to be operational. This can be achieved by doing so (still in the `hashicorp-vault` namespace), here with *n* = *m* = 1 :

`kubectl exec hashicorp-vault-i -- vault operator unseal $VAULT_UNSEAL_KEY`, with *i* going from 0 to the number of pods.

Now, your vault is fully operational. First authentication is possible with the root token. The vault has to been unsealed everytime a pod is destroyed, or for any other reasons detailed in Hashicorp Vault's documentation.

### Automatic configuration

The Vault may be automatically initialized and unsealed. This is done by executing the script `init.sh` in the `vault` folder, with the following command : `./init.sh`. Then follow the instructions and your Vault should be ready to use at the end.

**Initial configuration**

This part is not mandatory. It deploys the Key/Value engine on the Vault, as well as a Kubernetes backend for authentication (for instance used by the argocd-vault plugin).
The k8s backend has read-access on the path `kv/*`.

Go to the `vault` folder, create a `terraform.tfvars` and fill it with the required variables. The `vault_root_token` may be found in the previously generated `cluster-keys.json`file. Then do a `terraform init`, followed by `terraform plan`, then `terraform apply`.

**Congratulations! Your Hashicorp Vault is now ready to use, enjoy!**

## Velero

Velero is a backup and restore tool for Kubernetes. It is used to backup the cluster's resources, and to restore them in case of disaster. It is also used to migrate the cluster to another provider.

### Configuration

**Installation**

Before you run the `terraform apply`command, update your `terraform.tfvars` file with the following variables :
```velero_version              = YOUR_VELERO_VERSION
velero_s3_bucket_endpoint   = YOUR_S3_BUCKET_ENDPOINT
velero_s3_bucket_region     = YOUR_S3_BUCKET_REGION
velero_s3_bucket_name       = YOUR_S3_BUCKET_NAME
velero_s3_access_key_id     = YOUR_S3_ACCESS_KEY_ID
velero_s3_secret_access_key = YOUR_S3_SECRET_ACCESS_KEY
```

**Manual backup**

To backup the cluster, you need to create a backup file. This is done with the following command : `velero backup create BACKUP_NAME`. You can list your backups with `velero backup get`.

**Schedule a backup**

To schedule a backup of your namespace, just refer to the template `common/Schedlule-template.yaml.template` and fill it with the correct values. Then apply it with `kubectl apply -f Schedlule-template.yaml`.

**Restore from backup**

To restore from a backup, run the following command, with *BACKUP_NAME* being the name of the backup you want to restore from : `velero restore --from-backup BACKUP_NAME`.