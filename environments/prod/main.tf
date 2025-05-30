provider "azurerm" {
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  features {}
}

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.83.0, < 4.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }

  backend "azurerm" {
    resource_group_name   = "rg-secure-infra"
    storage_account_name  = "secureterraformstate123"
    container_name        = "tfstate"
    key                   = "prod.tfstate"
  }
}

data "azurerm_client_config" "current" {}

module "coreinfra" {
  source                 = "../../modules/coreinfra"
  resource_group_name    = "rg-prod-infra"
  location               = "eastus"
  name_prefix            = "prod"
  private_dns_zone_names = [
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.database.windows.net"
  ]
}

module "networking" {
  source                = "../../modules/networking"
  vnet_name             = "secure-vnet"
  location              = "eastus"
  resource_group        = "rg-prod-infra"
  address_space         = ["10.1.0.0/16"]
  subnet_names          = ["web-tier", "app-tier", "db-tier", "AzureFirewallSubnet"]
  subnet_prefixes       = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
  name_prefix           = "prod"
  private_dns_zone_names = [
    "privatelink.blob.core.windows.net",
    "privatelink.database.windows.net",
    "privatelink.vaultcore.azure.net"
  ]
}

module "keyvault" {
  source          = "../../modules/keyvault"
  name_prefix     = "prod"
  location        = "eastus"
  resource_group  = "rg-prod-infra"
  tenant_id       = var.azure_tenant_id
  admin_object_id = data.azurerm_client_config.current.object_id
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
  source            = "../../modules/aks"
  name_prefix       = "prod"
  location          = module.coreinfra.location
  resource_group    = module.coreinfra.resource_group_name
  identity_name     = "prod-identity"
  service_account   = "prod-sa"
  oidc_issuer_url   = "" # replace with actual output from AKS module
}



module "firewall" {
  source                = "../../modules/firewall"
  name_prefix           = "prod"
  location              = module.coreinfra.location
  resource_group        = module.coreinfra.resource_group_name
  firewall_subnet_id    = module.networking.firewall_subnet_id
  subnet_ids_to_protect = [module.networking.subnet_ids[1]] # app-tier
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
  source                = "../../modules/logicapp"
  name_prefix           = "prod"
  location              = module.coreinfra.location
  resource_group        = module.coreinfra.resource_group_name
  logic_app_id          = "12ca8a72-eb2a-4154-9a76-7d39d1f20f7f"          # Replace with actual logic app ID or output
  logic_app_trigger_url = ""         # Replace with actual trigger URL
  workspace_id          = module.sentinel.workspace_id       # Make sure sentinel module exports this
}

module "simulations" {
  source            = "../../modules/simulations"
  name_prefix       = "prod"
  location          = module.coreinfra.location
  resource_group    = module.coreinfra.resource_group_name
  subnet_id         = module.networking.subnet_ids[1] # app-tier
  key_vault_id      = module.keyvault.key_vault_id
  principal_id      = module.aks.client_id
  key_vault_name    = module.keyvault.name
}

module "sentinel" {
  source          = "../../modules/sentinel"
  location        = module.coreinfra.location
  resource_group  = module.coreinfra.resource_group_name
  workspace_name  = "law-prod"
  azure_tenant_id = var.azure_tenant_id
  logic_app_id = module.logicapp.logic_app_id
  logic_app_trigger_url = module.logicapp.logic_app_trigger_url
  workspace_id = azurerm_log_analytics_workspace.law.id

  depends_on = [module.coreinfra]
}



module "iam" {
  source = "../../modules/iam"

  identity_name   = "prod-identity"
  location        = module.coreinfra.location
  resource_group  = module.coreinfra.resource_group_name
  oidc_issuer_url = module.aks.oidc_issuer_url
  namespace       = "default"
  service_account = "prod-sa"
  key_vault_id    = module.keyvault.key_vault_id
  principal_id    = module.aks.client_id
  scope           = module.aks.aks_id
}



