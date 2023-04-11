variable "letsencrypt_email" {
  type        = string
  description = "Email address that Let's Encrypt will use to send notifications about expiring certificates and account-related issues to."
  sensitive   = true
  default     = "bralequepautto-8984@yopmail.com"
}

variable "cluster_issuer_name" {
  type        = string
  description = "Name of the clusterIssuer"
  default     = "cert-manager-global"
}
