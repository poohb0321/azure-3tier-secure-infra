resource "azurerm_resource_group_template_deployment" "logicapp" {
  name                = "${var.name_prefix}-logicapp-deploy"
  resource_group_name = var.resource_group
  deployment_mode     = "Incremental"

  template_content = file("${path.module}/workflow.json")

  parameters_content = jsonencode({
    location = {
      value = var.location
    }
    "$connections" = {
      value = {
        office365 = {
          connectionId   = "/subscriptions/0a7eb3ba-cd21-4466-91fd-04134b38423f/resourceGroups/rg-prod-infra/providers/Microsoft.Web/connections/office365"
          connectionName = "office365"
          id             = "/subscriptions/0a7eb3ba-cd21-4466-91fd-04134b38423f/providers/Microsoft.Web/locations/eastus/managedApis/office365"
        }
      }
    }
  })
}
