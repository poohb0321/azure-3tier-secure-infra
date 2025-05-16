provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.83.0, < 4.0.0 "
    }
  }

  backend "azurerm" {
    resource_group_name   = "rg-secure-infra"
    storage_account_name  = "secureterraformstate123"
    container_name        = "tfstate"
    key                   = "dev.tfstate"
  }
}

resource "azurerm_resource_group" "dev" {
  name     = "rg-dev-infra"
  location = "East US"
}

module "networking" {
  source          = "../../modules/networking"
  vnet_name       = "dev-vnet"
  location        = azurerm_resource_group.dev.location
  resource_group  = azurerm_resource_group.dev.name
  address_space   = ["10.1.0.0/16"]
  subnet_names    = ["web-tier", "app-tier", "appgw-subnet"]
  subnet_prefixes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

resource "azurerm_public_ip" "appgw" {
  name                = "appgw-public-ip"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "waf" {
  source         = "../../modules/waf"
  appgw_name     = "appgw-dev"
  location       = azurerm_resource_group.dev.location
  resource_group = azurerm_resource_group.dev.name
  subnet_id      = module.networking.subnet_ids[2]
  public_ip_id   = azurerm_public_ip.appgw.id
}

module "sentinel" {
  source         = "../../modules/sentinel"
  workspace_name = "law-dev"
  location       = azurerm_resource_group.dev.location
  resource_group = azurerm_resource_group.dev.name
}

module "keyvault" {
  source          = "../../modules/keyvault"
  name            = "kv-dev-pooja-0321"
  location        = azurerm_resource_group.dev.location
  resource_group  = azurerm_resource_group.dev.name
  tenant_id       = "3547f3ce-b3af-40c6-bb98-3a1d7ee844bd"
  admin_object_id = "36563b85-7113-4da4-9b15-b44a34595c5c"
}

module "simulations" {
  source          = "../../modules/simulations"
  location        = "East US"
  resource_group  = "rg-dev-infra"
  key_vault_id    = module.keyvault.key_vault_id
  key_vault_name  = "kv-dev"
}

