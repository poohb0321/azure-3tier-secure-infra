resource "azurerm_user_assigned_identity" "sim_identity" {
  name                = "sim-identity"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_key_vault_secret" "sim_secret" {
  name         = "sim-secret"
  value        = "SensitiveInformation123"
  key_vault_id = var.key_vault_id
  depends_on   = [var.key_vault_id]
}

resource "null_resource" "simulate_secret_access" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Simulating secret access..."
      az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
      az keyvault secret show --vault-name ${var.key_vault_name} --name sim-secret
EOT

    environment = {
      ARM_CLIENT_ID     = var.client_id
      ARM_CLIENT_SECRET = var.client_secret
      ARM_TENANT_ID     = var.tenant_id
    }
  }
}
