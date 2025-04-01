module "networking" {
  source         = "./modules/networking"
  vnet_name      = "secure-vnet"
  location       = "East US"
  resource_group = "rg-secure-infra"
  address_space  = ["10.0.0.0/16"]
  subnet_names   = ["web-tier", "app-tier"]
  subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "security" {
  source         = "./modules/security"
  location       = "East US"
  resource_group = "rg-secure-infra"
}
