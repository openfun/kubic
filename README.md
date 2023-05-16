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
- Copy the `credentials.auto.tfvars.json.template` to `credentials.auto.tfvars.json` and fill it with the corresponding credentials (you need to create API keys from your providers). Terraform will automaticaly generate a certificate and use it for the vault;
  - For OVH, see [here](https://help.ovhcloud.com/csm/en-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042777#advanced-usage-pair-ovhcloud-apis-with-an-application)
  - For Scaleway, see [here](https://www.scaleway.com/en/docs/identity-and-access-management/iam/how-to/create-api-keys/)
- Do a `terraform init -backend-config=backend.conf`, then `terraform plan` then `terraform apply` to create your cluster. Doing so, your Terraform state will be saved in the s3 bucket.

_Using the OVH provider, you may encounter timeouts, or other errors. (coming from OVH) If so, simply re-run the `terraform apply` command. It will continue where it stopped and will eventually complete._

## Hashicorp Vault

Once the cluster has been setup, Hashicorp Vault (now referred to as "vault") is not ready for use. It has to be initialized and to be unsealed. _Secrets will be handled in the following steps._
To ensure HA on the cluster, the deployment consists of 3 pods, spread on 3 nodes. (the node autoscaling feature is used here). More pods can be created by modifying Terraform's vars. (HPA is not available though).

_To perform the following steps, you need to have every pod in the `Running` state. You can check this with `kubectl get pods -n hashicorp-vault`. (they won't be marked as ready however)_

### Manual initialization

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

### Automatic configuration

The Vault may be automatically initialized and unsealed. This is done by executing the script `init.sh` in the `vault` folder, with the following command : `./init.sh`. Then follow the instructions and your Vault should be ready to use at the end.

**Initial configuration**

This part is not mandatory. It deploys the Key/Value engine on the Vault, as well as a Kubernetes backend for authentication (for instance used by the argocd-vault plugin).
The k8s backend has read-access on the path `kv/*`.

Go to the `vault` folder, create a `terraform.tfvars` and fill it with the required variables. The `vault_root_token` may be found in the previously generated `cluster-keys.json`file. Then do a `terraform init`, followed by `terraform plan`, then `terraform apply`.

**Congratulations! Your Hashicorp Vault is now ready to use, enjoy!**

## ArgoCD

### The mono-repo

The mono-repo is a git repository containing all the applications you want to deploy on your cluster. It is used by ArgoCD to deploy your applications. It is a good practice to have a mono-repo for each cluster you have.

This project shares a mono-repo structure which was specifically designed to ease the deployment of applications for new k8s users. It is available [here](examples/argocd-repo). However, you may be free to use your own repository structure.

The repostiory structure is the following :

```bash
.
├── .gitignore
├── apps                                # Folder containing all the applications to declare
│   ├── external-app                    # Folder declaring the external-app application
│   │   └── test.json
│   ├── hello-world                     # Folder declaring the hello-world application
│   │   ├── preprod.json
│   │   ├── prod.json
│   │   └── staging.json
│   └── secret-helm                     # Folder declaring the secret-helm application
│       ├── base.yaml
│       ├── dev.json
│       ├── dev.yaml
│       ├── prod.json
│       └── prod.yaml
└── helm                                # Folder containing all the helm charts
    ├── hello-world                     # Folder containing the hello-world helm chart
    │   ├── .helmignore
    │   ├── Chart.yaml
    │   ├── README.md
    │   ├── templates
    │   │   ├── NOTES.txt
    │   │   ├── _helpers.tpl
    │   │   ├── deployment.yaml
    │   │   ├── service.yaml
    │   │   └── serviceaccount.yaml
    │   └── values.yaml
    └── secret-helm                     # Folder containing the secret-helm helm chart
        ├── .DS_Store
        ├── .helmignore
        ├── Chart.yaml
        ├── templates
        │   ├── .DS_Store
        │   └── secret.yaml
        └── values.yaml
```

### Usage

1. Create a new repository with the same structure as the mono-repo
2. Create read credentials for the repository
3. Configure accordingly the Terraform variables `argocd_repo_url`, `argocd_repo_username` and `argocd_repo_password` (see [variables.tf](common/variables.tf))
4. Define the variables `argocd_hostname` and `argocd_password` (see [variables.tf](common/variables.tf)). The variable `argocd_password` is used to define the password of the `admin` user of ArgoCD. Terraform expects a **hash** of the password. To generate it, you can use the following command : `argocd account bcrypt --password P@$sw0rd` after installing ArgoCD CLI.

### ArgoCD Vault Plugin

The ArgoCD Vault Plugin is a plugin for ArgoCD which allows to use secrets stored in Hashicorp Vault in your applications. It is installed by default on the cluster. You can fine tune its version by changing the variable `argocd_avp_version` (see [variables.tf](common/variables.tf)). It is highly recommended to read the [documentation](http://argocd-vault-plugin.readthedocs.io) of the plugin before using it as many undocumented here features are available and may suit your needs.

By default, ArgoCD Vault Plugin is configured to use the Kubernetes auth backend of Vault. The authentication is done with the Kubernetes service account of ArgoCD in the `argocd` namespace. The service account has read access on the path `kv/*`. We'll see later how to restrict the access to the secrets for specific applications.

ArgoCD Vault Plugin works by taking a directory of YAML files that have been templated out using the pattern of `<placeholder>` and then using the values from Vault to replace the placeholders. The plugin will then apply the YAML files to the cluster. You can use generic or inline placeholders. An inline-path placeholder allows you to specify the path, key, and optionally, the version to use for a specific placeholder. This means you can inject values from multiple distinct secrets in your secrets manager into the same YAML.

Valid examples:

```
- <path:some/path#secret-key>
- <path:some/path#secret-key#version>
```

If the version is omitted (first example), the latest version of the secret is retrieved.
By default, Vault creates a KV-V2 backends. For KV-V2 backends, the path needs to be specified as `<path:${vault-kvv2-backend-path}/data/{path-to-secret}>` where `vault-kvv2-backend-path` is the path to the KV-V2 backend and `path-to-secret` is the path to the secret in Vault.

Again, **it is highly recommended to read the [placeholders documentation](https://argocd-vault-plugin.readthedocs.io/en/stable/howitworks/) of the plugin before using it**.
