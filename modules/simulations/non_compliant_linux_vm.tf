resource "azurerm_linux_virtual_machine" "non_compliant" {
  name                = "badvm-${var.name_prefix}"
  resource_group_name = var.resource_group
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.vm_nic.id]

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

  disable_password_authentication = false
  admin_password                  = "Azure12345678" # not secure, just for simulation
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
