variable "resource_group_name" {
  type        = string
  description = "The resource name of the resource group."
}

variable "location" {
  type        = string
  description = "The location of the resources."

  validation {
    condition     = contains(["westeurope"], var.location)
    error_message = "Resource location is not allowed. Valid values are westeurope."
  }
}

variable "tenant_id" {
  type = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "key_vault_name" {
  description = "Name of the key vault e.g. kv-example"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$", var.key_vault_name))
    error_message = "Key vault name must comply with regex ^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$."
  }

  validation {
    condition     = 3 <= length(var.key_vault_name) && length(var.key_vault_name) <= 24
    error_message = "Key vault name must be between 3 and 24 characters."
  }
}

variable "key_vault_sku_name" {
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku_name)
    error_message = "Allowed values are standard and premium."
  }
}

variable "key_vault_tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault."
  type        = string
}

variable "key_vault_soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  type        = number
  default     = 90
}

variable "key_vault_enable_purge_protection" {
  description = "Boolean to enable purge protection. Purge protection prevents you from deleting soft-deleted vaults and objects, and is recommended for production deployments. Defaults to false."
  type        = bool
  default     = false
}

variable "key_vault_enable_rbac_authorization" {
  description = "Boolean to enable rbac authorization on key vault resource. Disabled by default."
  type        = bool
  default     = false
}

variable "service_principal_client_id" {
  type = string
}