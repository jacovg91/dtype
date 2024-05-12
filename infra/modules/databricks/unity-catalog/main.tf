resource "databricks_metastore_assignment" "assign_workspace_to_uc" {
  provider     = databricks.account
  metastore_id = var.metastore_id
  workspace_id = var.databricks_workspace_id
}