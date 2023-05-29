terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.30.0"
    }
  }
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.application_key
  application_secret = var.application_secret
  consumer_key       = var.consumer_key
}

# Configure the AWS Provider
provider "aws" {
  region     = var.s3_region
  access_key = ovh_cloud_project_user_s3_credential.s3_admin_cred.access_key_id
  secret_key = ovh_cloud_project_user_s3_credential.s3_admin_cred.secret_access_key

  # OVH implementation has no STS service
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  # the gra region is unknown to AWS hence skipping is needed.
  skip_region_validation = true
  endpoints {
    s3 = var.s3_endpoint
  }
}
