# Velero

Velero is a backup and restore tool for Kubernetes. It is used to backup the cluster's resources, and to restore them in case of disaster. It is also used to migrate the cluster to another provider.

## Configuration

Before using Velero, all you need is an external S3 bucket to store your backups. You can use any S3 compatible storage provider. 

**Installation**

Before you run the `terraform apply`command, update your `terraform.tfvars` file with the following variables, according to your S3 provider :
```velero_version              = YOUR_VELERO_VERSION
velero_s3_bucket_endpoint   = YOUR_S3_BUCKET_ENDPOINT
velero_s3_bucket_region     = YOUR_S3_BUCKET_REGION
velero_s3_bucket_name       = YOUR_S3_BUCKET_NAME
velero_s3_access_key_id     = YOUR_S3_ACCESS_KEY_ID
velero_s3_secret_access_key = YOUR_S3_SECRET_ACCESS_KEY
```

**Set persistent volumes backup**

We use the opt-in approach from Velero to backup persistent volumes (more information [here](https://velero.io/docs/main/file-system-backup/)). This means that you need to add the following annotation to your pods, when you want its PVC to be saved : `backup.velero.io/backup-volumes: <volumes_names>, ...`. This will backup the persistent volume claim and the persistent volume associated with it.

## Velero's CLI

Velero comes with a CLI to manage the backups. You can install it [here](https://velero.io/docs/v1.6/basic-install/). To bind the CLI to your cluster, just set the `--kubeconfig` flag when you run a command. Otherwise, Velero will use your default kubeconfig file.

**Manual backup**

To backup the cluster, you need to create a backup file. This is done with the following command : `velero backup create BACKUP_NAME`. You can list your backups with `velero backup get`.

**Auto backup**

To schedule a backup of your namespace, just refer to the template `common/Schedlule-template.yaml.template` and fill it with the correct values. Then apply it with `kubectl apply -f Schedlule-template.yaml`.

**Restore from backup**

To restore from a backup, run the following command, with *BACKUP_NAME* being the name of the backup you want to restore from : `velero restore create --from-backup BACKUP_NAME`.