output "assigned_roles" {
  value = azurerm_role_assignment.assignments
}

output "identity_id" {
  value = azurerm_user_assigned_identity.aks_identity.id
}

output "role_assignment_id" {
  value = azurerm_role_assignment.assign_custom_role.id
}
