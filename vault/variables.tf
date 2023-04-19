variable "vault_root_token" {
    type        = string
    description = "The root token of the Vault server"
    sensitive   = true
}

variable "vault_url" {
    type        = string
    description = "The URL of the Vault server"
}