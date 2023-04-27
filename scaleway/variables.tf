variable "scaleway_access_key" {
  type        = string
  description = "The access key to use for Scaleway API calls"
  sensitive   = true
}

variable "scaleway_secret_key" {
  type        = string
  description = "The secret key to use for Scaleway API calls"
  sensitive   = true
}

variable "scaleway_project_id" {
  type        = string
  description = "The project id to use for Scaleway API calls"
  sensitive   = true
}

variable "scaleway_region" {
  type        = string
  description = "The region to use for the cluster"
  default     = "fr-par"
}

variable "k8s_cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = "joy"
}
