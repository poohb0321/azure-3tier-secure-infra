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

variable "subnet_id" {
  description = "Subnet ID for the VM"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to append to resource names"
  type        = string
}