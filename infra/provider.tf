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
  backend "azurerm" {
    resource_group_name  = var.state_resource_group_name
    storage_account_name = var.state_storage_account_name
    container_name       = var.state_storage_container_name
    key                  = "state.tfstate"
  }
}

provider "azurerm" {
  subscription_id            = var.subscription_id
  skip_provider_registration = "true"
  features {}
}