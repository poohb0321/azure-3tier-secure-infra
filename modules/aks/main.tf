resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.name_prefix}-aks"
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = "${var.name_prefix}-aks"

  default_node_pool {
    name       = "systempool"
    node_count = 1
    vm_size    = "Standard_D4s_v3"
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled          = true
  workload_identity_enabled    = true

  kubernetes_version = "1.32.4"
  sku_tier           = "Free"
}

resource "azurerm_role_assignment" "aks_reader" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Reader"
  scope                = azurerm_kubernetes_cluster.aks.id
}
