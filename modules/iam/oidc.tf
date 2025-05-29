resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = var.identity_name
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_federated_identity_credential" "aks_workload" {
  name                = "${var.identity_name}-fid"
  resource_group_name = var.resource_group
  parent_id           = azurerm_user_assigned_identity.aks_identity.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:${var.namespace}:${var.service_account}"
}
