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

module "networking" {
  source          = "../../modules/networking"
  vnet_name       = "dev-vnet"
  name_prefix     = "dev"
  location        = module.coreinfra.location
  resource_group  = module.coreinfra.resource_group_name
  address_space   = ["10.1.0.0/16"]
  subnet_names    = ["web-tier", "app-tier", "appgw-subnet", "AzureFirewallSubnet"]
  subnet_prefixes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
  private_dns_zone_names = [
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
  public_ip_id   = azurerm_public_ip.appgw.id
}

module "aks" {
  source         = "../../modules/aks"
  name_prefix    = "dev"
  location       = module.coreinfra.location
  resource_group = module.coreinfra.resource_group_name
}

module "iam" {
  source = "../../modules/iam"
  principal_id    = module.aks.client_id
  scope           = module.coreinfra.resource_group_name
  resource_group  = module.coreinfra.resource_group_name
  location        = module.coreinfra.location
  identity_name   = "aks-workload-mi"
  namespace       = "default"
  service_account = "workload-identity-sa"
  oidc_issuer_url = module.aks.oidc_issuer_url
  key_vault_id    = module.keyvault.key_vault_id
}


module "keyvault" {
  source          = "../../modules/keyvault"
  name_prefix     = "kv-dev-pooja-0321"
  location        = azurerm_resource_group.dev.location
  resource_group  = azurerm_resource_group.dev.name
  tenant_id       = "3547f3ce-b3af-40c6-bb98-3a1d7ee844bd"
  admin_object_id = "36563b85-7113-4da4-9b15-b44a34595c5c"
}

module "sentinel" {
  source                 = "../../modules/sentinel"
  workspace_name         = "law-dev"
  location               = module.coreinfra.location
  resource_group         = module.coreinfra.resource_group_name
  azure_tenant_id        = "3547f3ce-b3af-40c6-bb98-3a1d7ee844bd"
  azure_subscription_id  = "0a7eb3ba-cd21-4466-91fd-04134b38423f"
  workspace_id           = module.sentinel.workspace_id

  logic_app_id           = module.logicapp.logic_app_id
  logic_app_trigger_url  = module.logicapp.logic_app_trigger_url
}


module "simulations" {
  source          = "../../modules/simulations"
  location        = azurerm_resource_group.dev.location
  resource_group  = azurerm_resource_group.dev.name
  key_vault_id    = module.keyvault.key_vault_id
  key_vault_name  = module.keyvault.key_vault_name
  subnet_id      = module.networking.subnet_ids["subnet-web"]
  name_prefix    = "dev"
}

module "defender" {
  source           = "../../modules/defender"
  enabled_services = [
    "AppServices",
    "KeyVaults",
    "KubernetesService",
    "StorageAccounts",
    "DevOps"
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

module "policy" {
  source = "../../modules/policy"
  scope  = module.coreinfra.resource_group_id 
  workspace_id = module.sentinel.workspace_id 
}

resource "azurerm_linux_virtual_machine" "non_compliant" {
  name                = "testlinux-vm-noagent"
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location
  size                = "Standard_B1ls"
  admin_username      = "azureuser"
  network_interface_ids = [module.networking.linux_nic_id]

  admin_password = "SuperSecure123!" # Avoid for prod – use key-based login instead

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

