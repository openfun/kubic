########################################################################################
# This script creates an S3 bucket along with 1 S3 user
########################################################################################

########################################################################################
#     User / Credential
########################################################################################

# Used to create the bucket
resource "ovh_cloud_project_user" "s3_admin_user" {
  service_name = var.ovh_public_cloud_project_id
  description  = "${var.user_desc_prefix} that is used to create S3 access key"
  role_name    = "objectstore_operator"
}
resource "ovh_cloud_project_user_s3_credential" "s3_admin_cred" {
  service_name = var.ovh_public_cloud_project_id
  user_id      = ovh_cloud_project_user.s3_admin_user.id
}

# Given to the user for Terraform
resource "ovh_cloud_project_user" "write_user" {
  service_name = var.ovh_public_cloud_project_id
  description = "${var.user_desc_prefix} that will have write access to the bucket"
  role_name = "objectstore_operator"
}

resource "ovh_cloud_project_user_s3_credential" "write_cred"{
  service_name = var.ovh_public_cloud_project_id
  user_id = ovh_cloud_project_user.write_user.id
}

########################################################################################
#     Bucket
########################################################################################
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

########################################################################################
#     Policy
########################################################################################

resource "ovh_cloud_project_user_s3_policy" "write_policy" {
  service_name = var.ovh_public_cloud_project_id
  user_id      = ovh_cloud_project_user.write_user.id
  policy       = jsonencode({
    "Statement":[{
      "Sid": "RWContainer",
      "Effect": "Allow",
      "Action":["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListMultipartUploadParts", "s3:ListBucketMultipartUploads", "s3:AbortMultipartUpload", "s3:GetBucketLocation"],
      "Resource":["arn:aws:s3:::${aws_s3_bucket.bucket.bucket}", "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"]
    }]
  })
}

########################################################################################
#     Output
########################################################################################
output "access_key" {
  description = "the access key that have been created by the terraform script"
  value       = ovh_cloud_project_user_s3_credential.write_cred.access_key_id
}

output "secret_key" {
  description = "the secret key that have been created by the terraform script"
  value       = ovh_cloud_project_user_s3_credential.write_cred.secret_access_key
  sensitive   = true
}

# Redundancy since the bucket name is provided as a variable
output "bucket_name" {
  description = "The name of the bucket that has been created by the Terraform script"
  value       = aws_s3_bucket.bucket.bucket
}