resource "azurerm_key_vault" "keyvault" {
  resource_group_name = var.resource_group_name
  name                = var.key_vault_name
  location            = var.location
  sku_name            = var.key_vault_sku_name
  tenant_id           = var.key_vault_tenant_id
  tags                = var.tags

  soft_delete_retention_days = var.key_vault_soft_delete_retention_days
  purge_protection_enabled   = var.key_vault_enable_purge_protection

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  lifecycle {
    ignore_changes = [
      access_policy # Access policies are managed using `azurerm_key_vault_access_policy` resources
    ]
  }
}