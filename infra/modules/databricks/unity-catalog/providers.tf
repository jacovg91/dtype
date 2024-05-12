terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.30.0"
    }
  }

  # Remote state settings
  backend "azurerm" {}
}

provider "databricks" {
  alias                       = "workspace"
  host                        = var.databricks_workspace_url
  azure_workspace_resource_id = var.databricks_workspace_id
}

# Initialize provider at Azure account-level
provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}