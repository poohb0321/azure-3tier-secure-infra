output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "client_id" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
