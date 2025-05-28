resource "random_string" "suffix" {
  length  = 6
  upper   = false
  number  = true
  special = false
}

resource "azurerm_key_vault" "main" {
  name                            = "${var.name_prefix}-kv-${random_string.suffix.result}" 
  location                        = var.location
  resource_group_name             = var.resource_group
  tenant_id                       = var.tenant_id
  sku_name                        = "standard"
  soft_delete_retention_days      = 7
  purge_protection_enabled        = true
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
}

resource "azurerm_key_vault_access_policy" "admin" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = var.tenant_id
  object_id    = var.admin_object_id

  key_permissions = [
    "Get", "List", "Create", "Delete"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete"
  ]
}
