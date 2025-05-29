resource "azurerm_user_assigned_identity" "sim_identity" {
  name                = "sim-identity"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_key_vault_secret" "sim_secret" {
  name         = "sim-secret"
  value        = "SensitiveInformation123"
  key_vault_id = var.key_vault_id
}

resource "null_resource" "simulate_secret_access" {
  provisioner "local-exec" {
    command = <<EOT
      echo " Simulating Key Vault secret access..."
      az keyvault secret show --vault-name ${var.key_vault_name} --name sim-secret
EOT
  }

  depends_on = [
    azurerm_key_vault_secret.sim_secret
  ]
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "non_compliant" {
  name                = "badvm-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Azure12345678"  # ⚠️ Just for testing. Don't use in real workloads.

  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "badvmosdisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    # Intentionally missing 'Environment' tag to trigger policy
    purpose = "non-compliant-test"
  }
}

