resource "azurerm_role_assignment" "assign_custom_role" {
  scope              = var.scope
  role_definition_id = azurerm_role_definition.custom_storage_reader.role_definition_resource_id
  principal_id       = var.principal_id
}
