resource "azurerm_log_analytics_workspace" "law" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_sentinel_alert_rule_scheduled" "suspicious_login" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel]
  name                       = "SuspiciousLogin"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Suspicious Login from Unfamiliar Location"
  severity                   = "High"
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0

  query = <<QUERY
SigninLogs
| where ResultType == 50074
| extend timestamp = TimeGenerated, AccountCustomEntity = UserPrincipalName
QUERY
}
