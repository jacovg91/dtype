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