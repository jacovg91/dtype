variable "environment" {
  type = string
}

variable "location" {
  type        = string
  description = "The location of the resources"

  validation {
    condition     = contains(["westeurope"], var.location)
    error_message = "Resource location is not allowed. Only valid version is westeurope."
  }
}

variable "resource_group_name" {
  type = string

}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account"

  validation {
    condition     = can(regex("[a-z0-9]+$", var.storage_account_name)) || length(var.storage_account_name) < 3 || length(var.storage_account_name) > 24
    error_message = "Storage_account_name must be between 3 and 24 characters, regex [a-z0-9]+$."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resources"
}

variable "storage_account_account_tier" {
  type        = string
  default     = "Standard"
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium."

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_account_tier)
    error_message = "Variable storage_account_account_tier must be Standard or Premium."
  }
}

variable "storage_account_replication_type" {
  type        = string
  default     = "ZRS"
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Variable storage_account_replication_type must be one of LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  }
}

variable "service_principal_client_id" {
  type = string
}