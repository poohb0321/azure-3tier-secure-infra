variable "azure_client_id" {}
variable "azure_client_secret" {}

variable "admin_object_id" {
  description = "The Object ID of the admin user or SP needing access to Key Vault"
  type        = string
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}



