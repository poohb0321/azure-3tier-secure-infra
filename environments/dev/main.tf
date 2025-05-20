provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.90.0, < 4.0.0"
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
  name_prefix     = "dev"
  location        = module.coreinfra.location
  resource_group  = module.coreinfra.resource_group_name
  address_space   = ["10.1.0.0/16"]
  subnet_names    = ["web-tier", "app-tier", "appgw-subnet"]
  subnet_prefixes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_dns_zone_names  = [
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.database.windows.net"
  ]
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
  location       = module.coreinfra.location
  resource_group = module.coreinfra.resource_group_name
  subnet_id      = module.networking.appgw_subnet_id
  public_ip_id   = module.coreinfra.public_ip_id
}

module "sentinel" {
  source           = "../../modules/sentinel"
  workspace_name   = "law-dev"
  location         = module.coreinfra.location
  resource_group   = module.coreinfra.resource_group_name
  azure_tenant_id        = "3547f3ce-b3af-40c6-bb98-3a1d7ee844bd"
  azure_subscription_id  = "0a7eb3ba-cd21-4466-91fd-04134b38423f"
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
  location        = azurerm_resource_group.dev.location
  resource_group  = azurerm_resource_group.dev.name
  key_vault_id    = module.keyvault.key_vault_id
  key_vault_name  = module.keyvault.key_vault_name
}

module "coreinfra" {
  source                = "../../modules/coreinfra"
  resource_group_name   = "rg-dev-infra"
  location              = "East US"
  name_prefix           = "dev"
  private_dns_zone_names = [
  "privatelink.vaultcore.azure.net",
  "privatelink.blob.core.windows.net",
  "privatelink.database.windows.net"
]
}

module "aks" {
  source         = "../../modules/aks"
  name_prefix    = "dev"
  location       = module.coreinfra.location
  resource_group = module.coreinfra.resource_group_name
}

module "iam" {
  source = "../../modules/iam"

  assignments = {
    # AKS to Reader on its own resource
    aks_reader = {
      principal_id = module.aks.client_id
      role         = "Reader"
      scope        = module.aks.aks_id
    }
    
  create_custom_role       = true
  custom_role_name         = "StorageBlobReaderCustom"
  custom_role_description  = "Read-only access to Blob Storage"
  custom_role_scope        = module.coreinfra.resource_group_name
  custom_role_actions      = [
    "Microsoft.Storage/storageAccounts/blobServices/containers/read",
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"
  ]

    # AKS to Key Vault Secrets User
    aks_kv = {
      principal_id = module.aks.client_id
      role         = "Key Vault Secrets User"
      scope        = module.keyvault.key_vault_id
    }
  }
}

module "defender" {
  source           = "../../modules/defender"
  enabled_services = [
    "AppServices",
    "KeyVaults",
    "KubernetesService",
    "StorageAccounts"
  ]
}

module "logicapp" {
  source         = "../../modules/logicapp"
  name_prefix    = "dev"
  location       = module.coreinfra.location
  resource_group = module.coreinfra.resource_group_name
}

module "firewall" {
  source                = "../../modules/firewall"
  name_prefix           = "dev"
  location              = module.coreinfra.location
  resource_group        = module.coreinfra.resource_group_name
  firewall_subnet_id    = module.networking.firewall_subnet_id
  subnet_ids_to_protect = [module.networking.subnet_ids[1]]
}