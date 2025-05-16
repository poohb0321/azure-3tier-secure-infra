variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group" {
  description = "Resource group name"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault resource ID"
  type        = string
}

variable "key_vault_name" {
  description = "Key Vault name"
  type        = string
}

variable "client_id" {
  description = "Service principal client ID"
  type        = string
}

variable "client_secret" {
  description = "Service principal client secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}
