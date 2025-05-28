variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group" {
  description = "Resource group name"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "admin_object_id" {
  description = "Object ID of the admin or SP needing access"
  type        = string
}

variable "name_prefix" {
  description = "Prefix used to create unique Key Vault name"
  type        = string
}