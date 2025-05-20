output "location" {
  value = var.location
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "public_ip_id" {
  value = azurerm_public_ip.appgw.id
}
