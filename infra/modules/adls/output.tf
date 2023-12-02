output "storage_account_id" {
  description = "Resource ID of the Storage Account."
  value       = azurerm_storage_account.datalake.id
}

output "storage_account_name" {
  description = "Name of the Storage Account."
  value       = azurerm_storage_account.datalake.name
}

output "storage_account_primary_access_key" {
  description = "Primary access key of the Storage Account."
  value       = azurerm_storage_account.datalake.primary_access_key
}

output "storage_account_secondary_access_key" {
  description = "Secondary access key of the Storage Account."
  value       = azurerm_storage_account.datalake.secondary_access_key
}