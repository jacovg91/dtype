output "databricks_workspace_id" {
  description = "Resource ID of the Databricks workspace."
  value       = azurerm_databricks_workspace.workspace.id
}

output "databricks_workspace_workspace_id" {
  description = "Databricks ID of the Databricks workspace, refers to the Databricks control plane."
  value       = azurerm_databricks_workspace.workspace.workspace_id
}

output "databricks_workspace_url" {
  description = "URL of the Databricks workspace e.g. adb-{workspaceId}.{random}.azuredatabricks.net"
  value       = azurerm_databricks_workspace.workspace.workspace_url
}

output "databricks_workspace_datasource_dependency" {
  description = "Dependency to use as databricks datasource [depends_on](https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs#data-resources-and-authentication-is-not-configured-errors)."
  value       = azurerm_databricks_workspace.workspace
}