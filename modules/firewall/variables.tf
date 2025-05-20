variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "firewall_subnet_id" {
  description = "Subnet ID for the Azure Firewall"
  type        = string
}

variable "subnet_ids_to_protect" {
  description = "List of subnet IDs to associate route table"
  type        = list(string)
}
