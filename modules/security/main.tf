resource "azurerm_security_center_subscription_pricing" "defender" {
  tier          = "Standard"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "secure-nsg"
  location            = var.location
  resource_group_name = var.resource_group
}
