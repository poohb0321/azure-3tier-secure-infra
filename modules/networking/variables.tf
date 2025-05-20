variable "vnet_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnet_names" {
  type = list(string)
}

variable "subnet_prefixes" {
  type = list(string)
}

variable "name_prefix" {
  description = "Prefix for naming network resources"
  type        = string
}

variable "private_dns_zone_names" {
  description = "List of Private DNS Zone names to link"
  type        = list(string)
}
