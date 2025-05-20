output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  value = azurerm_subnet.subnets[*].id
}

output "subnet_names" {
  value = azurerm_subnet.subnets[*].name
}

output "appgw_subnet_id" {
  description = "ID of the Application Gateway subnet (assuming it's the 3rd one)"
  value       = element(azurerm_subnet.subnets[*].id, 2)
}

output "firewall_subnet_id" {
  description = "ID of the Azure Firewall subnet (assuming it's the 4th one)"
  value       = length(azurerm_subnet.subnets) > 3 ? element(azurerm_subnet.subnets[*].id, 3) : null
}

output "web_nsg_id" {
  value = azurerm_network_security_group.web.id
}

output "app_nsg_id" {
  value = azurerm_network_security_group.app.id
}

output "db_nsg_id" {
  value = azurerm_network_security_group.db.id
}

output "private_dns_zone_links" {
  value = azurerm_private_dns_zone_virtual_network_link.links
}
