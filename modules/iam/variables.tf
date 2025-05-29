variable "create_custom_role" {
  type        = bool
  description = "Whether to create a custom role"
  default     = false
}

variable "custom_role_name" {
  type        = string
  description = "Name of the custom role"
  default     = ""
}

variable "custom_role_description" {
  type        = string
  description = "Description of the custom role"
  default     = ""
}

variable "custom_role_scope" {
  type        = string
  description = "Scope for the custom role"
  default     = ""
}

variable "custom_role_actions" {
  type        = list(string)
  description = "List of actions for the custom role"
  default     = []
}

variable "principal_id" {
  description = "The object ID of the identity (user, AKS, or DevOps)"
  type        = string
}

variable "scope" {
  description = "Scope to assign the role to (e.g., resource or resource group)"
  type        = string
}

variable "identity_name" {
  description = "Name of the user-assigned managed identity"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for workload identity"
  type        = string
}

variable "service_account" {
  description = "Kubernetes service account name for workload identity"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL from AKS cluster"
  type        = string
}

variable "resource_group" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault resource ID for assigning RBAC"
  type        = string
}

