resource "azurerm_databricks_workspace" "workspace" {
  resource_group_name = var.resource_group_name
  name                = var.databricks_workspace_name
  location            = var.location
  tags                = var.tags

  sku = "premium"

  managed_resource_group_name = var.databricks_workspace_managed_resource_group_name
}