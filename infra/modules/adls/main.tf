resource "azurerm_storage_account" "datalake" {
  resource_group_name      = var.resource_group_name
  name                     = var.storage_account_name
  location                 = var.location
  account_tier             = var.storage_account_account_tier
  account_replication_type = var.storage_account_replication_type
  tags                     = var.tags

  account_kind   = "StorageV2"
  is_hns_enabled = true
  access_tier    = "Hot"

  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
}

resource "azurerm_storage_container" "adls_container" {
  name                 = "lake"
  storage_account_name = azurerm_storage_account.datalake.name
}

# The service principal needs access to the storage account for databricks mounting.
resource "azurerm_role_assignment" "sbdc" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.service_principal_client_id
}