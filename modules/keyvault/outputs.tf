output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "key_vault_id" {
  description = "The ID of the Key Vault"
  value = azurerm_key_vault.main.id
}

output "key_vault_name" {
  value       = azurerm_key_vault.main.name
  description = "The name of the Key Vault"
}