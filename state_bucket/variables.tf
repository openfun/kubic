variable "ovh_public_cloud_project_id" {
  type        = string
  description = "The OVH public cloud project id"
}

variable "application_key" {
  type        = string
  description = "The application key to use for OVH API calls"
  sensitive   = true
}

variable "application_secret" {
  type        = string
  description = "The application secret to use for OVH API calls"
  sensitive   = true
}

variable "consumer_key" {
  type        = string
  description = "The consumer key to use for OVH API calls"
  sensitive   = true
}

variable "s3_region" {
  type        = string
  description = "The region for the s3 bucket"
  default     = "gra"
}

variable "s3_endpoint" {
  type        = string
  description = "The endpoint for the s3 bucket"
  default     = "https://s3.gra.io.cloud.ovh.net/"
}

variable "user_desc_prefix" {
  type    = string
  default = "User for TF backend state storage"
}

variable "bucket_name" {
  type    = string
  default = "tf-k8s-state-storage"
}
