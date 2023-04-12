variable "ovh_public_cloud_project_id" {
  type = string
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

variable "region" {
  type    = string
  default = "gra"
}

variable "user_desc_prefix" {
  type    = string
  default = "User for TF backend state storage"
}

variable "bucket_name" {
  type    = string
  default = "tf-state-storage"
}
