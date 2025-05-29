# output "logic_app_id" {
#   value = azurerm_logic_app_workflow.alert_handler.id
# }

# output "logic_app_trigger_url" {
#   value = azurerm_logic_app_workflow.alert_handler.access_endpoint_url
# }

output "logic_app_id" {
  value = azurerm_logic_app_workflow.logicapp.id
}

output "logic_app_trigger_url" {
  value = azurerm_logic_app_trigger_http_request.trigger.callback_url
}
