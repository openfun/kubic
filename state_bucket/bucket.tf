########################################################################################
# This script creates an S3 bucket along with 1 S3 user
########################################################################################

########################################################################################
#     User / Credential
########################################################################################
resource "ovh_cloud_project_user" "s3_admin_user" {
  service_name = var.ovh_public_cloud_project_id
  description  = "${var.user_desc_prefix} that is used to create S3 access key"
  role_name    = "objectstore_operator"
}
resource "ovh_cloud_project_user_s3_credential" "s3_admin_cred" {
  service_name = var.ovh_public_cloud_project_id
  user_id      = ovh_cloud_project_user.s3_admin_user.id
}

########################################################################################
#     Bucket
########################################################################################
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
}


########################################################################################
#     Output
########################################################################################
output "access_key" {
  description = "the access key that have been created by the terraform script"
  value       = ovh_cloud_project_user_s3_credential.s3_admin_cred.access_key_id
}

output "secret_key" {
  description = "the secret key that have been created by the terraform script"
  value       = ovh_cloud_project_user_s3_credential.s3_admin_cred.secret_access_key
  sensitive   = true
}
