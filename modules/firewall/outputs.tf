output "firewall_private_ip" {
  value = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

output "firewall_id" {
  value = azurerm_firewall.main.id
}
