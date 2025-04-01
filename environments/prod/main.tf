terraform {
  backend "azurerm" {
    resource_group_name   = "rg-secure-infra"
    storage_account_name  = "secureterraformstate"
    container_name        = "tfstate"
    key                   = "prod.tfstate"
  }
}

module "networking" {
  source         = "../../modules/networking"
  vnet_name      = "prod-vnet"
  location       = "East US"
  resource_group = "rg-prod-infra"
  address_space  = ["10.2.0.0/16"]
  subnet_names   = ["web-tier", "app-tier"]
  subnet_prefixes = ["10.2.1.0/24", "10.2.2.0/24"]
}
