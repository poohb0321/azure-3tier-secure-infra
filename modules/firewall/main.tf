resource "azurerm_public_ip" "firewall" {
  name                = "${var.name_prefix}-firewall-pip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "main" {
  name                = "${var.name_prefix}-firewall"
  location            = var.location
  resource_group_name = var.resource_group
  sku_name = "AZFW_VNet"
  sku_tier = "Standard"
  threat_intel_mode   = "Alert"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_route_table" "firewall_rt" {
  name                = "${var.name_prefix}-firewall-rt"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_route" "firewall_default" {
  name                   = "default-to-firewall"
  resource_group_name    = var.resource_group
  route_table_name       = azurerm_route_table.firewall_rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
  count          = length(var.subnet_ids_to_protect)
  subnet_id      = element(var.subnet_ids_to_protect, count.index)
  route_table_id = azurerm_route_table.firewall_rt.id
}
