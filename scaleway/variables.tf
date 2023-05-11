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
  default     = "my_cluster"
}

variable "k8s_cluster_version" {
  type        = string
  description = "The version of the cluster"
  default     = "1.27.1"
}

variable "k8s_nodepool_name" {
  type        = string
  description = "The name of the pool"
  default     = "my_pool"
}

variable "k8s_nodepool_flavor" {
  type        = string
  description = "The flavor of the pool"
  default     = "DEV1-M"
}

variable "k8s_nodepool_size" {
  type        = number
  description = "The size of the pool"
  default     = 1
}
