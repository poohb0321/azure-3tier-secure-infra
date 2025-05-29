data "azurerm_subscription" "primary" {}

resource "azurerm_role_definition" "custom_storage_reader" {
  name        = "CustomStorageReader"
  scope       = data.azurerm_subscription.primary.id
  description = "Can read specific storage accounts"

  permissions {
    actions     = ["Microsoft.Storage/storageAccounts/read"]
    not_actions = []
  }

  assignable_scopes = [data.azurerm_subscription.primary.id]
}
