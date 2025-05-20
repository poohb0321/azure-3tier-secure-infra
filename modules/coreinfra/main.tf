resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_public_ip" "appgw" {
  name                = "${var.name_prefix}-appgw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = toset(var.private_dns_zone_names)
  name                = each.value
  resource_group_name = azurerm_resource_group.this.name
}
