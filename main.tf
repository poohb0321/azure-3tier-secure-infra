terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.90.0, < 4.0.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "infra" {
  name     = "rg-secure-infra"
  location = "eastus"
}

module "networking" {
  source          = "./modules/networking"
  vnet_name       = "secure-vnet"
  name_prefix = "prod"
  location        = azurerm_resource_group.infra.location
  resource_group  = azurerm_resource_group.infra.name
  address_space   = ["10.0.0.0/16"]
  subnet_names    = ["web-tier", "app-tier"]
  subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24"]
  private_dns_zone_names  = [
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.database.windows.net"
  ]
}

module "security" {
  source         = "./modules/security"
  location       = azurerm_resource_group.infra.location
  resource_group = azurerm_resource_group.infra.name
}
