
data "databricks_metastore" "unity_catalog_metastore" {
  name = var.environment == "dev" ? databricks_metastore.metastore.name : "dtype-store-we"
}

resource "azurerm_storage_account" "unity_catalog_metastore_storage" {
  count                    = var.environment == "dev" ? 1 : 0
  resource_group_name      = var.unity_catalog_resource_group_name
  name                     = "stdtypeucmetastore"
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.common_tags

  account_kind   = "StorageV2"
  is_hns_enabled = true
  access_tier    = "Hot"

  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  depends_on = [module.databricks_workspace]
}

resource "azurerm_storage_container" "unity_catalog" {
  count                = var.environment == "dev" ? 1 : 0
  name                 = "metastore"
  storage_account_name = azurerm_storage_account.unity_catalog_metastore_storage[count.index].name
}

resource "databricks_metastore" "metastore" {
  count = var.environment == "dev" ? 1 : 0
  name  = "dtype-store-we"

  region = "westeurope"

  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog[0].name,
  azurerm_storage_account.unity_catalog_metastore_storage[0].name)
  owner         = "contact@innovion.nl"
  force_destroy = true
  depends_on    = [module.databricks_workspace]
}

resource "databricks_metastore_assignment" "assign_workspace_to_uc" {
  provider     = databricks.account
  metastore_id = data.databricks_metastore.unity_catalog_metastore.id
  workspace_id = var.databricks_workspace_id
}