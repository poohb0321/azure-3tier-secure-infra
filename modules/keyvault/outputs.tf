output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "key_vault_id" {
  description = "The ID of the Key Vault"
  value = azurerm_key_vault.main.id
}
