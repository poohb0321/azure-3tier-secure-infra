resource "azurerm_security_center_subscription_pricing" "defender" {
  for_each = toset(var.enabled_services)

  tier          = "Standard"
  resource_type = each.key
}
