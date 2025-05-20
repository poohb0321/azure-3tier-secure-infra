provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.83.0, < 4.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name   = "rg-secure-infra"
    storage_account_name  = "secureterraformstate123"
    container_name        = "tfstate"
    key                   = "prod.tfstate"
  }
}

module "coreinfra" {
  source                  = "../../modules/coreinfra"
  resource_group_name     = "rg-prod-infra"
  location                = "East US"
  name_prefix             = "prod"
  private_dns_zone_names  = [
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.database.windows.net"
  ]
}

module "networking" {
  source                 = "../../modules/networking"
  name_prefix            = "prod"
  vnet_name              = "prod-vnet"
  location               = module.coreinfra.location
  resource_group         = module.coreinfra.resource_group_name
  address_space          = ["10.2.0.0/16"]
  subnet_names           = ["web-tier", "app-tier", "appgw-subnet", "AzureFirewallSubnet"]
  subnet_prefixes        = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24", "10.2.4.0/24"]
  private_dns_zone_names = [
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.database.windows.net"
  ]
}

module "keyvault" {
  source           = "../../modules/keyvault"
  name             = "kv-prod-pooja-0321"
  location         = module.coreinfra.location
  resource_group   = module.coreinfra.resource_group_name
  tenant_id        = "3547f3ce-b3af-40c6-bb98-3a1d7ee844bd"
  admin_object_id  = "36563b85-7113-4da4-9b15-b44a34595c5c"
}

module "waf" {
  source         = "../../modules/waf"
  appgw_name     = "appgw-prod"
  location       = module.coreinfra.location
  resource_group = module.coreinfra.resource_group_name
  subnet_id      = module.networking.appgw_subnet_id
  public_ip_id   = module.coreinfra.public_ip_id
}

module "aks" {
  source         = "../../modules/aks"
  name_prefix    = "prod"
  location       = module.coreinfra.location
  resource_group = module.coreinfra.resource_group_name
}

module "iam" {
  source = "../../modules/iam"

  assignments = {
    aks_reader = {
      principal_id = module.aks.client_id
      role         = "Reader"
      scope        = module.aks.aks_id
    }

    aks_kv = {
      principal_id = module.aks.client_id
      role         = "Key Vault Secrets User"
      scope        = module.keyvault.key_vault_id
    }
  }
}

module "firewall" {
  source                = "../../modules/firewall"
  name_prefix           = "prod"
  location              = module.coreinfra.location
  resource_group        = module.coreinfra.resource_group_name
  firewall_subnet_id    = module.networking.firewall_subnet_id
  subnet_ids_to_protect = [module.networking.subnet_ids[1]] # app-tier
}

module "sentinel" {
  source                 = "../../modules/sentinel"
  workspace_name         = "law-prod"
  location               = module.coreinfra.location
  resource_group         = module.coreinfra.resource_group_name
  azure_tenant_id        = "3547f3ce-b3af-40c6-bb98-3a1d7ee844bd"
  azure_subscription_id  = "0a7eb3ba-cd21-4466-91fd-04134b38423f"
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
  name_prefix    = "prod"
  location       = module.coreinfra.location
  resource_group = module.coreinfra.resource_group_name
}
