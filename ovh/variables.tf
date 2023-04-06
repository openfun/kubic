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

variable "cluster-region" {
  type        = string
  description = "The region to use for the cluster"
  default     = "GRA5"
}

variable "service_name" {
  type        = string
  description = "The service name to use for the cluster"
}