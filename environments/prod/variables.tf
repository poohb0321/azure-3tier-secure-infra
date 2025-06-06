variable "admin_object_id" {
  description = "Object ID of Key Vault admin"
  type        = string
}

variable "azure_subscription_id" {
  type = string
}

variable "azure_tenant_id" {
  type = string
}

variable "azure_client_id" {
  type = string
}

variable "azure_client_secret" {
  type = string
}

variable "oidc_issuer_url" {
  type = string
}