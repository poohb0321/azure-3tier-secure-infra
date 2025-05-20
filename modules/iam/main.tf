resource "azurerm_role_assignment" "assignments" {
  for_each             = var.assignments
  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = each.value.principal_id
}

resource "azurerm_role_definition" "custom" {
  count       = var.create_custom_role ? 1 : 0
  name        = var.custom_role_name
  scope       = var.custom_role_scope
  description = var.custom_role_description

  permissions {
    actions     = var.custom_role_actions
    not_actions = []
  }

  assignable_scopes = [var.custom_role_scope]
}
