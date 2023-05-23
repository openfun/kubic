
# ArgoCD

**Before reading this section, please note that disabling the installation of Hashicorp Vault will also disable the installation of ArgoCD Vault Plugin. You are still able to use ArgoCD the way you want but you will have to use your own repo structure.**

## The mono-repo

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

## Usage

1. Create a new repository with the same structure as the mono-repo
2. Create read credentials for the repository (see [here](https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/#access-token) for different providers)
3. Configure accordingly the Terraform variables `argocd_repo_url`, `argocd_repo_username` and `argocd_repo_password` (see [variables.tf](common/variables.tf)). **Terraform expects HTTP git credentials, not SSH.**
4. Define the variables `argocd_hostname` and `argocd_password` (see [variables.tf](common/variables.tf)). The variable `argocd_password` is used to define the password of the `admin` user of ArgoCD. Terraform expects a **hash** of the password. To generate it, you can use the following command : `argocd account bcrypt --password P@$sw0rd` after installing ArgoCD CLI.

## ArgoCD Vault Plugin

The ArgoCD Vault Plugin is a plugin for ArgoCD which allows to use secrets stored in Hashicorp Vault in your applications. It is installed by default on the cluster. You can fine tune its version by changing the variable `argocd_avp_version` (see [variables.tf](common/variables.tf)). It is highly recommended to read the [documentation](http://argocd-vault-plugin.readthedocs.io) of the plugin before using it as it has many undocumented features in this README that may suit your needs.

By default, ArgoCD Vault Plugin is configured to use the Kubernetes auth backend of Vault. The authentication is done with the Kubernetes service account of ArgoCD in the `argocd` namespace. The service account has read access on the path `kv/*`. We'll see later how to restrict the access to the secrets for specific applications.

ArgoCD Vault Plugin works by taking a directory of YAML files that have been templated out using the pattern of `<placeholder>` and then using the values from Vault to replace the placeholders. The plugin will then apply the YAML files to the cluster. You can use generic or inline placeholders. However, inline placeholders are more straightforward to use. An inline-path placeholder allows you to specify the path, key, and optionally, the version to use for a specific placeholder. This means you can inject values from multiple distinct secrets in your secrets manager into the same YAML.

Valid examples:

```
- <path:some/path#secret-key>
- <path:some/path#secret-key#version>
```

If the version is omitted (first example), the latest version of the secret is retrieved.
By default, Vault creates a KV-V2 backend. For KV-V2 backends, the path needs to be specified as `<path:${vault-kvv2-backend-path}/data/{path-to-secret}>` where `vault-kvv2-backend-path` is the path to the KV-V2 backend and `path-to-secret` is the path to the secret in Vault.

Again, **it is highly recommended to read the [placeholders documentation](https://argocd-vault-plugin.readthedocs.io/en/stable/howitworks/) of the plugin before using it**.

## Examples

### Basic example - hello-world application

This example shows how to deploy a simple application with ArgoCD. The application is a simple nginx server. The application is deployed in 3 environments: staging, preprod and prod. The application is deployed in 3 different namespaces, one namespace per application and per environment.

The application is deployed with the following instructions :

- Add the `hello-world` helm chart to the `helm` folder of the mono-repo
- Declare the application in the `apps` folder of the mono-repo by creating a folder named `hello-world`. **Beware of the name of the folder, it must be the same as the name of the helm chart.**
- Add a JSON file per environnement and name the file according to the following pattern : `<environment>.json`. For instance, for the staging environment, the file must be named `staging.json`. This file **must be a valid JSON file and must contain at least** :

```json
{}
```

### ArgoCD Vault Plugin example - secret-helm application

This example shows how to use the ArgoCD Vault Plugin to deploy a helm chart with secrets stored in Hashicorp Vault. The application is a simple chart which creates a secret with with various keys and values. The application is deployed in 2 environments: dev and prod. The application is deployed in 2 different namespaces, one namespace per application and per environment.

The application configuration refers to specific helm values per environment. The used value files are declared for each environment using the JSON file. The JSON file must contain the following:

```json
{
  "valuesFiles": ["<path-to-values-file>"]
}
```

For instance, the prod environment uses the `prod.json` file with:

```json
{
  "valuesFiles": ["base.yaml", "prod.yaml"]
}
```

### Multi-tenancy example - external-app application

This example shows how to deploy an application in a multi-tenant environment. The cluster administrator is responsible for declaring the application on the cluster and the developers are responsible for maintaining the application helm chart. This is achieved by specifying the `externalRepoURL` in the JSON file.

For instance, the test environment uses the `test.json` file with:

```json
{
  "externalRepoURL": "https://github.com/example/externalRepo.git"
}
```

Beware the distant repository must be public or the cluster must have access to it. Please refer to the [ArgoCD documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories) for more information.

Please also note that the distant repository must have the exact same structure as the mono-repo. The distant repository must contain a `helm` folder with the helm charts and an `apps` folder with the application configuration:

```bash
.
├── apps
│   └── external-app
│       └── test.yaml
└── helm
    └── external-app
        ├── .helmignore
        ├── Chart.yaml
        ├── charts
        ├── templates
        └── values.yaml
```

Just like that, the developer who controls the helm chart is able to request any secret contained in the vault just by using the correct path
of a secret in the vault. Therefore, the cluster administrator must restrict the access to the secrets for specific applications. This is achieved by following this procedure :

1. Create a specific policy in Vault for the application which only gives access to the secrets needed by the application
2. Attach the policy to the Vault Authentication Method
3. Create an ArgoCD Vault Plugin configuration secret which uses the Vault Authentication Method. Please refer to the [ArgoCD Vault Plugin backend documentation](https://argocd-vault-plugin.readthedocs.io/en/stable/backends/) and the [ArgoCD Vault Plugin configuration documentation](https://argocd-vault-plugin.readthedocs.io/en/stable/config/) for more information. Here is an example of a configuration secret for AppRole authentication:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: external-vault-credentials
  namespace: argocd
type: Opaque
stringData:
  VAULT_ADDR: Your HashiCorp Vault Address
  AVP_TYPE: vault
  AVP_AUTH_TYPE: approle
  AVP_ROLE_ID: Your AppRole Role ID
  AVP_SECRET_ID: Your AppRole Secret ID
```

Beware, the secret **must** be created in the `argocd` namespace.

4. Finally, reference the vault credentials secret in the JSON file:

```json
{
  "vaultCredentials": "external-vault-credentials"
}
```

Please note that if you do not want to use external repositories, you can still declare a helm chart in the mono-repo which calls an external chart which has to be stored on a helm repository.
