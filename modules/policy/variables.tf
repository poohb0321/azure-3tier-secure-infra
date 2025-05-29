variable "scope" {
  description = "Scope (usually a subscription or resource group ID)"
  type        = string
}

variable "workspace_id" {
  description = "Log Analytics workspace ID for VM monitoring"
  type        = string
}
