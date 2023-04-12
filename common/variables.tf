variable "cluster_issuer_name" {
  type        = string
  description = "Name of the clusterIssuer"
  default     = "cert-manager-global"
}

variable "letsencrypt_email" {
  type        = string
  description = "Email address to use for the clusterIssuer"
}

variable "s3_access_key" {
  type        = string
  description = "The access key to use for S3 API calls"
  sensitive   = true
}

variable "s3_secret_key" {
  type        = string
  description = "The secret key to use for S3 API calls"
  sensitive   = true
}

variable "s3_endpoint" {
  type        = string
  description = "The endpoint to use for S3 API calls"
  default     = "https://s3.gra.io.cloud.ovh.net"
}

variable "s3_bucket_name" {
  type        = string
  description = "The bucket name to use for S3 API calls"
  default     = "tf-s3-bucket-scaleway"
}

variable "grafana_hostname" {
    type        = string
    description = "The hostname to use for the Grafana ingress"
}