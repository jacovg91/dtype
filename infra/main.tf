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
  name     = module.naming_key_vault.resource_group.name
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
  source               = "./modules/adls"
  environment          = var.environment
  resource_group_name  = azurerm_resource_group.adls_rg.name
  location             = var.location
  storage_account_name = module.naming.storage_account.name
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
}

# Databricks workspace
module "databricks_workspace" {
  source                                           = "./modules/databricks/workspace"
  resource_group_name                              = azurerm_resource_group.databricks_rg.name
  databricks_workspace_name                        = module.naming.databricks_workspace.name
  databricks_workspace_managed_resource_group_name = "rg-m-dbw-dtype-${var.environment}"
  location                                         = var.location
}