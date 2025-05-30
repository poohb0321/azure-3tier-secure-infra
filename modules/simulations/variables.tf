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

variable "resource_group" {
  description = "Resource group to deploy the VM"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the VM"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to append to resource names"
  type        = string
}

variable "principal_id" {
  type = string
}