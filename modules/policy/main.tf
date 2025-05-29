variable "scope" {
  description = "Scope at which the policy assignment will be applied"
  type        = string
}

variable "workspace_id" {
  description = "Log Analytics workspace ID used in audit policies"
  type        = string
}

# === CUSTOM POLICY DEFINITIONS ===

resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "deny-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Public IP on NICs"
  policy_rule  = file("${path.module}/rules/deny-public-ip.json")
}

resource "azurerm_policy_definition" "require_encryption" {
  name         = "require-storage-encryption"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require Storage Encryption"
  policy_rule  = file("${path.module}/rules/require-encryption.json")
}

resource "azurerm_policy_definition" "deny_basic_sku" {
  name         = "deny-basic-sku"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Basic SKU"
  policy_rule  = file("${path.module}/rules/deny-basic-sku.json")
}

resource "azurerm_policy_definition" "require_https" {
  name         = "require-https-storage"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require HTTPS for Storage Accounts"
  policy_rule  = file("${path.module}/rules/require-https.json")
}

resource "azurerm_policy_definition" "require_diagnostics" {
  name         = "require-diagnostics"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Audit NSG without diagnostics"
  policy_rule  = file("${path.module}/rules/require-diagnostics.json")
}

resource "azurerm_policy_definition" "enforce_tags" {
  name         = "enforce-env-tag"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce 'env=prod' Tag"
  policy_rule  = file("${path.module}/rules/enforce-tags.json")
}

# === BUILT-IN POLICY DATA SOURCES ===

data "azurerm_policy_definition" "deny_rdp" {
  display_name = "Deny RDP access from Internet"
}

data "azurerm_policy_definition" "deny_ssh" {
  display_name = "Deny SSH access from Internet"
}

data "azurerm_policy_definition" "deny_public_ip_builtin" {
  display_name = "Not allowed resource types"
}

data "azurerm_policy_definition" "audit_storage_https" {
  display_name = "Storage accounts should restrict network access"
}

data "azurerm_policy_definition" "audit_linux_agent" {
  display_name = "Audit Linux VMs without the Log Analytics agent"
}

data "azurerm_policy_definition" "audit_windows_agent" {
  display_name = "Audit Windows VMs without the Log Analytics agent"
}

data "azurerm_policy_definition" "require_tag_env" {
  display_name = "Require a tag on resources"
}

# === POLICY SET DEFINITION ===

resource "azurerm_policy_set_definition" "security_initiative" {
  name         = "secure-policy-baseline"
  display_name = "Secure Policy Baseline"
  policy_type  = "Custom"

  # Custom policies
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_public_ip.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_encryption.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_basic_sku.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_https.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_diagnostics.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.enforce_tags.id
  }

  # Built-in policies with and without parameters
  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.deny_rdp.id
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.deny_ssh.id
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.deny_public_ip_builtin.id
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.audit_storage_https.id
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.audit_linux_agent.id
    parameter_values = jsonencode({
      "effect" = { "value" = "Audit" },
      "workspaceId" = { "value" = var.workspace_id }
    })
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.audit_windows_agent.id
    parameter_values = jsonencode({
      "effect" = { "value" = "Audit" },
      "workspaceId" = { "value" = var.workspace_id }
    })
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.require_tag_env.id
    parameter_values = jsonencode({
      "tagName" = { "value" = "Environment" }
    })
  }
}

# === POLICY ASSIGNMENT ===

resource "azurerm_policy_assignment" "baseline_assignment" {
  name                 = "secure-policy-assignment"
  policy_definition_id = azurerm_policy_set_definition.security_initiative.id
  scope                = var.scope
  enforce              = true
}
