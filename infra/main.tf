# --------------------------
# General Input
# --------------------------

locals {
  project_name = "dtype"
  common_tags = {
    Now_Location    = "NL"
    Now_Environment = var.environment
    ApplicationName = local.project_name
    ModifiedAt      = timestamp()
  }
}

# --------------------------
# Data blocks
# --------------------------

data "azurerm_client_config" "current" {
}

data "azuread_service_principal" "service_principal" {
  display_name = var.service_principal_name
}

data "azuread_service_principal" "dbw_sp" {
  display_name = "AzureDatabricks"
}

# --------------------------
# Resource Groups
# --------------------------

resource "azurerm_resource_group" "adls_rg" {
  name     = module.naming_storage.resource_group.name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "key_vault_rg" {
  name     = module.naming_key_vault.resource_group.name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "databricks_rg" {
  name     = module.naming_databricks.resource_group.name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "unity_catalog_metastore_rg" {
  count    = var.environment == "prd" ? 1 : 0
  name     = "rg-metastore-dtype"
  location = var.location
  tags     = local.common_tags
}

# --------------------------
# Modules
# --------------------------

# Naming (taken from https://github.com/Azure/terraform-azurerm-naming)
module "naming" {
  source = "./modules/utilities/naming"
  suffix = [local.project_name, var.environment]
}

# Naming Storage
module "naming_storage" {
  source = "./modules/utilities/naming"
  suffix = ["st", local.project_name, var.environment]
}

module "naming_key_vault" {
  source = "./modules/utilities/naming"
  suffix = ["kv", local.project_name, var.environment]
}

# Naming Databricks
module "naming_databricks" {
  source = "./modules/utilities/naming"
  suffix = ["dbw", local.project_name, var.environment]
}

# Storage
module "adls" {
  source                      = "./modules/adls"
  environment                 = var.environment
  resource_group_name         = azurerm_resource_group.adls_rg.name
  location                    = var.location
  storage_account_name        = module.naming.storage_account.name
  service_principal_client_id = data.azuread_service_principal.service_principal.object_id
}

# Key Vault
module "key_vault" {
  source                               = "./modules/key-vault"
  location                             = var.location
  resource_group_name                  = azurerm_resource_group.key_vault_rg.name
  key_vault_sku_name                   = "standard"
  key_vault_name                       = module.naming.key_vault.name
  key_vault_soft_delete_retention_days = "90"
  key_vault_tenant_id                  = data.azurerm_client_config.current.tenant_id
  tenant_id                            = data.azurerm_client_config.current.tenant_id
  service_principal_client_id          = data.azuread_service_principal.service_principal.object_id
}

resource "azurerm_key_vault_access_policy" "spn_kv_admin_access_policies" {
  key_vault_id = module.key_vault.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.service_principal.object_id

  key_permissions    = []
  secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
}

# Databricks workspace
module "databricks_workspace" {
  source                                           = "./modules/databricks/workspace"
  resource_group_name                              = azurerm_resource_group.databricks_rg.name
  databricks_workspace_name                        = module.naming.databricks_workspace.name
  databricks_workspace_managed_resource_group_name = "rg-m-dbw-dtype-${var.environment}"
  location                                         = var.location
}

resource "databricks_secret_scope" "kv_scope" {
  name = "databricks-secrets"

  depends_on = [module.databricks_workspace]
}

resource "databricks_secret" "service_principal_key" {
  key          = "service-principal-key"
  string_value = var.service_principal_secret
  scope        = databricks_secret_scope.kv_scope.name
  depends_on = [
    module.databricks_workspace,
    module.key_vault
  ]
}

resource "databricks_secret" "adls_key" {
  key          = "adls-storage-key"
  string_value = module.adls.storage_account_primary_access_key
  scope        = databricks_secret_scope.kv_scope.name
  depends_on = [
    module.databricks_workspace,
    module.key_vault
  ]
}
resource "databricks_cluster" "mounter" {
  cluster_name            = "Mounter"
  spark_version           = "13.3.x-scala2.12"
  node_type_id            = "Standard_F4s"
  autotermination_minutes = 10
  autoscale {
    min_workers = 1
    max_workers = 1
  }
  depends_on = [
    module.databricks_workspace,
    module.adls
  ]
}

resource "databricks_mount" "mounting_filesystems" {
  for_each   = var.databricks_mounts
  name       = each.value
  cluster_id = databricks_cluster.mounter.id
  wasb {
    container_name       = each.value
    storage_account_name = module.adls.storage_account_name
    auth_type            = "ACCESS_KEY"
    token_secret_scope   = databricks_secret_scope.kv_scope.name
    token_secret_key     = databricks_secret.adls_key.key
  }

  depends_on = [
    module.databricks_workspace,
    module.adls
  ]
}

# Unity Catalog (only deploy once on prd since you can only have one metastore in one region)
resource "azurerm_storage_account" "unity_catalog_metastore_storage" {
  count                    = length(azurerm_resource_group.unity_catalog_metastore_rg)
  resource_group_name      = azurerm_resource_group.unity_catalog_metastore_rg[0].name
  name                     = "stdtypeucmetastore"
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags

  account_kind   = "StorageV2"
  is_hns_enabled = true
  access_tier    = "Hot"

  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  depends_on = [module.databricks_workspace]
}

resource "azurerm_storage_container" "unity_catalog" {
  count                = length(azurerm_resource_group.unity_catalog_metastore_rg)
  name                 = "metastore"
  storage_account_name = azurerm_storage_account.unity_catalog_metastore_storage[count.index].name
}

resource "databricks_metastore" "metastore" {
  count = length(azurerm_resource_group.unity_catalog_metastore_rg)
  name  = "dtype-store-we"

  region = "westeurope"

  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog[0].name,
  azurerm_storage_account.unity_catalog_metastore_storage[0].name)
  owner         = "contact@innovion.nl"
  force_destroy = true
  depends_on    = [module.databricks_workspace]
}

module "unity_catalog" {
  source = "./modules/databricks/unity-catalog"

  databricks_workspace_id  = module.databricks_workspace.databricks_workspace_id
  databricks_workspace_url = module.databricks_workspace.databricks_workspace_url
  databricks_account_id    = var.databricks_account_id
  metastore_id             = databricks_metastore.metastore.id
}
