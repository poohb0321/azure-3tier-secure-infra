terraform {
  backend "azurerm" {
    resource_group_name   = "rg-secure-infra"
    storage_account_name  = "secureterraformstate"
    container_name        = "tfstate"
    key                   = "dev.tfstate"
  }
}

module "networking" {
  source         = "../../modules/networking"
  vnet_name      = "dev-vnet"
  location       = "East US"
  resource_group = "rg-dev-infra"
  address_space  = ["10.1.0.0/16"]
  subnet_names   = ["web-tier", "app-tier"]
  subnet_prefixes = ["10.1.1.0/24", "10.1.2.0/24"]
}
