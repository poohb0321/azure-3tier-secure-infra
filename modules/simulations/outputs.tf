output "sim_identity_id" {
  description = "ID of the identity used to simulate secret access"
  value       = azurerm_user_assigned_identity.sim_identity.id
}

output "simulation_timestamp" {
  description = "Timestamp when simulation was last run"
  value       = null_resource.simulate_secret_access.triggers.run_simulation
}
