variable "workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
}

variable "resource_group" {
  description = "Name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID for Sentinel connectors"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID for Sentinel connectors (optional if not using activity connector)"
  type        = string
  default     = ""
}
