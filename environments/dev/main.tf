terraform {
  backend "azurerm" {
    resource_group_name   = "rg-secure-infra"
    storage_account_name  = "secureterraformstate"
    container_name        = "tfstate"
    key                   = "dev.tfstate"
  }
}

module "networking" {
  source          = "../../modules/networking"
  vnet_name       = "dev-vnet"
  location        = "East US"
  resource_group  = "rg-dev-infra"
  address_space   = ["10.1.0.0/16"]
  subnet_names    = ["web-tier", "app-tier", "appgw-subnet"]
  subnet_prefixes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

resource "azurerm_public_ip" "appgw" {
  name                = "appgw-public-ip"
  location            = "East US"
  resource_group_name = "rg-dev-infra"
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "waf" {
  source         = "../../modules/waf"
  appgw_name     = "appgw-dev"
  location       = "East US"
  resource_group = "rg-dev-infra"

  # Get the 3rd subnet from networking module (appgw-subnet)
  subnet_id      = module.networking.subnet_ids[2]

  # Use the public IP just created
  public_ip_id   = azurerm_public_ip.appgw.id
}

module "sentinel" {
  source         = "../../modules/sentinel"
  workspace_name = "law-dev"
  location       = "East US"
  resource_group = "rg-dev-infra"
}

module "keyvault" {
  source         = "../../modules/keyvault"
  name           = "kv-dev"
  location       = "East US"
  resource_group = "rg-dev-infra"
  tenant_id      = "3547f3ce-b3af-40c6-bb98-3a1d7ee844bd"   
  admin_object_id = "36563b85-7113-4da4-9b15-b44a34595c5c" 
}
