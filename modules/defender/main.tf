resource "azurerm_security_center_subscription_pricing" "defender" {
  for_each = toset(var.enabled_services)

  tier          = "Standard"
  resource_type = each.key
}

resource "azurerm_security_center_setting" "devops" {
  setting_name = "MCAS"
  enabled      = true
}

resource "azurerm_security_center_subscription_pricing" "devops" {
  tier          = "Standard"
  resource_type = "DevOps"
}
