resource "azurerm_resource_group_template_deployment" "logicapp" {
  name                = "${var.name_prefix}-logicapp-deploy"
  resource_group_name = var.resource_group
  deployment_mode     = "Incremental"

  template_content = file("${path.module}/workflow.json")

  parameters_content = jsonencode({
    location = {
      value = var.location
    }
  })
}
