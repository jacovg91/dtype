resource "azurerm_resource_group" "rg_adls" {
  name     = "rg-dtype-st-${var.environment}"
  location = var.location
}