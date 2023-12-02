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

provider "azurerm" {
  subscription_id            = var.subscription_id
  skip_provider_registration = "true"
  features {}
}