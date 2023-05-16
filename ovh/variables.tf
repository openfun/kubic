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

variable "ovh_public_cloud_project_id" {
  type        = string
  description = "The OVH public cloud project id"
}

variable "k8s_cluster_name" {
  type        = string
  description = "The name to use for the cluster"
  default     = "my_cluster"
}

variable "k8s_cluster_region" {
  type        = string
  description = "The region to use for the cluster"
  default     = "SBG5"
}

variable "k8s_cluster_version" {
  type        = string
  description = "The version to use for the cluster"
  default     = "1.26"
}

variable "k8s_nodepool_name" {
  type        = string
  description = "The name to use for the nodepool"
  default     = "default-pool"
}

variable "k8s_nodepool_flavor" {
  type        = string
  description = "The flavor to use for the nodepool"
  default     = "d2-4"
}

variable "k8s_nodepool_monthly_billed" {
  type        = bool
  description = "Whether the nodepool should be billed monthly or hourly"
  default     = false
}

variable "k8s_nodepool_min_nodes" {
  type        = number
  description = "The minimum number of nodes to use for the nodepool"
  default     = 2
}

variable "k8s_nodepool_max_nodes" {
  type        = number
  description = "The maximum number of nodes to use for the nodepool"
  default     = 10
}

variable "k8s_nodepool_desired_nodes" {
  type        = number
  description = "The desired number of nodes to use for the nodepool"
  default     = 2
}

variable "k8s_nodepool_autoscale" {
  type        = bool
  description = "Enable autoscaling feature (WIP)"
  default     = false
}