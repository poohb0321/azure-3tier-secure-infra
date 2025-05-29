data "azurerm_subscription" "current" {}

# Create a custom role definition
resource "azurerm_role_definition" "custom_storage_reader" {
  name        = "CustomStorageReader"
  scope       = data.azurerm_subscription.current.id
  description = "Read-only access to Storage blobs"

  permissions {
    actions     = ["Microsoft.Storage/storageAccounts/blobServices/containers/read", "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"]
    not_actions = []
  }

  assignable_scopes = [data.azurerm_subscription.current.id]
}

# Assign the custom role to the AKS-managed identity
resource "azurerm_role_assignment" "custom_role_assignment" {
  scope              = var.scope
  role_definition_id = azurerm_role_definition.custom_storage_reader.role_definition_resource_id
  principal_id       = var.principal_id
}

# Create a user-assigned managed identity
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = var.identity_name
  location            = var.location
  resource_group_name = var.resource_group
}

# Configure federated identity for AKS workload identity
resource "azurerm_federated_identity_credential" "aks_workload_identity" {
  name                = "${var.identity_name}-fid"
  resource_group_name = var.resource_group
  parent_id           = azurerm_user_assigned_identity.aks_identity.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:${var.namespace}:${var.service_account}"
}

resource "azurerm_role_assignment" "workload_identity_kv_access" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}