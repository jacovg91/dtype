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

resource "azurerm_key_vault_access_policy" "spn_kv_admin_access_policies" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = var.tenant_id
  object_id    = var.service_principal_client_id

  key_permissions    = []
  secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
}