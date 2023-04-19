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

## Hashicorp Vault

Once the cluster has been setup, Hashicorp Vault (now referred to as "vault") is not ready to use. It has to be initialized as well as to be unsealed. *Secrets will be handled in the following steps.*
To ensure HA on the cluster, the deployment consists of 3 pods, spread on 3 nodes. (the node autoscaling feature is used here). More pods can be created by modifying the Terraform's vars. (HPA is not available though). 

**Initialization of the vault**

Shamir's algorithm is used to encrypt the vault. *n* (with *n* > 0) are generated, and *m* keys (with 0 < *m* <= *n*) are needed to unseal the vault. This is achieved with the following command (using `kubectl` in the `hashicorp-vault` namespace):

```bash
kubectl exec hashicorp-vault-0 -- vault operator init \
    -key-shares=n \
    -key-threshold=m \
    -format=json > cluster-keys.json
```

This command generates a `cluster-keys.json` file containing :
* the *n* generated keys
* a root token, used to authenticate to the vault (once unsealed)

*If you read the doc, you might want to make the pods join the Raft cluster. The vault is here automatically set up to join the Raft cluster, so no action is required from the user here.*

**Unsealing of the vault**
The vault is still not available. Each pod must be *unsealed* to be operational. This can be achieved by doing so (still in the `hashicorp-vault` namespace), here with *n* = *m* = 1 :

`kubectl exec hashicorp-vault-i -- vault operator unseal $VAULT_UNSEAL_KEY`, with *i* going from 0 to the number of pods.

Now, your vault is fully operational. First authentication is possible with the root token. The vault has to been unsealed everytime a pod is destroyed, or for any other reasons detailed in Hashicorp Vault's documentation. 