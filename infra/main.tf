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

# --------------------------
# Modules
# --------------------------

# Naming
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
  object_id    = module.databricks_workspace.databricks_workspace_workspace_id

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
  name = "keyvault-managed"

  keyvault_metadata {
    resource_id = module.key_vault.key_vault_id
    dns_name    = module.key_vault.key_vault_url
  }
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

data "databricks_node_type" "smallest" {
  local_disk = true
  depends_on = [
    module.databricks_workspace
  ]
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  depends_on = [
    module.databricks_workspace
  ]
}

resource "databricks_cluster" "mounter" {
  cluster_name            = "Mounter"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
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