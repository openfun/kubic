# Hashicorp Vault

Once the cluster has been setup, Hashicorp Vault (now referred to as "vault") is not ready for use. It has to be initialized and to be unsealed. _Secrets will be handled in the following steps._
To ensure HA on the cluster, the deployment consists of 3 pods, spread on 3 nodes. (the node autoscaling feature is used here). More pods can be created by modifying Terraform's vars. (HPA is not available though).

_To perform the following steps, you need to have every pod in the `Running` state. You can check this with `kubectl get pods -n hashicorp-vault`. (they won't be marked as ready however)_

## Manual initialization

**Initialization of the vault**

Shamir's algorithm is used to encrypt the vault. _n_ keys (with _n_ > 0) are generated, and _m_ keys (with 0 < _m_ <= _n_) are needed to unseal the vault. This is achieved with the following command (using `kubectl` in the `hashicorp-vault` namespace):

```bash
kubectl exec hashicorp-vault-0 -- vault operator init \
    -key-shares=n \
    -key-threshold=m \
    -format=json > cluster-keys.json
```

This command generates a `cluster-keys.json` file containing :

- the _n_ generated keys
- a root token, used to authenticate to the vault (once unsealed)

_If you read the doc, you might want to make the pods join the Raft cluster. The vault is here configured to join the Raft cluster by itself, so no action is required from the user here._

**Unsealing of the vault**

The vault is still not available. Each pod must be _unsealed_ to be operational. This can be achieved by doing so (still in the `hashicorp-vault` namespace), here with _n_ = _m_ = 1 :

`kubectl exec hashicorp-vault-i -- vault operator unseal $VAULT_UNSEAL_KEY`, with _i_ going from 0 to the number of pods.

Now, your vault is fully operational. First authentication is possible with the root token. The vault has to been unsealed everytime a pod is destroyed, or for any other reasons detailed in Hashicorp Vault's documentation.

## Automatic configuration

The Vault may be automatically initialized and unsealed. This is done by executing the script `init.sh` in the `vault` folder, with the following command : `./init.sh`. Then follow the instructions and your Vault should be ready to use at the end.

**Initial configuration**

This part is not mandatory. It deploys the Key/Value engine on the Vault, as well as a Kubernetes backend for authentication (for instance used by the argocd-vault plugin).
The k8s backend has read-access on the path `kv/*`.

Go to the `vault` folder, create a `terraform.tfvars` and fill it with the required variables. The `vault_root_token` may be found in the previously generated `cluster-keys.json`file. Then do a `terraform init`, followed by `terraform plan`, then `terraform apply`.

**Congratulations! Your Hashicorp Vault is now ready to use, enjoy!**

Next step → [Configure ArgoCD](./argocd.md)