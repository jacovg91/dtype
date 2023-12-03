variable "resource_group_name" {
  description = "The resource name of the resource group"
  type        = string
}

variable "location" {
  type        = string
  description = "The location of the resources"

  validation {
    condition     = contains(["westeurope"], var.location)
    error_message = "Resource location is not allowed. Valid values is westeurope."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "A mapping of tags to assign to the resources"
}

variable "databricks_workspace_name" {
  type        = string
  description = "The name of the databricks workspace"

  validation {
    condition     = can(regex("[a-zA-Z0-9-_]+$", var.databricks_workspace_name)) || length(var.databricks_workspace_name) < 3 || length(var.databricks_workspace_name) > 30
    error_message = "Databricks workspace name must comply to regex [a-zA-Z0-9-_]+$."
  }

  validation {
    condition     = 3 <= length(var.databricks_workspace_name) && length(var.databricks_workspace_name) <= 30
    error_message = "Databricks workspace name must be between 3 and 30 characters."
  }
}

variable "databricks_workspace_managed_resource_group_name" {
  type        = string
  description = "The name of the databricks managed resource group"

  validation {
    condition     = can(regex("[a-zA-Z0-9-._\\(\\)]+[a-zA-Z0-9-_\\(\\)]$", var.databricks_workspace_managed_resource_group_name))
    error_message = "Databricks managed resource group name must comply to regex [a-zA-Z0-9-._\\(\\)]+[a-zA-Z0-9-_\\(\\)]$."
  }

  validation {
    condition     = 1 <= length(var.databricks_workspace_managed_resource_group_name) && length(var.databricks_workspace_managed_resource_group_name) <= 90
    error_message = "Databricks managed resource group name must be between 1 and 90 characters."
  }
}

variable "databricks_workspace_secure_cluster_connectivity" {
  description = "Indicates whether Secure cluster connectivity is enabled for the databricks workspace. Defaults to True. Read more at https://docs.microsoft.com/en-us/azure/databricks/security/secure-cluster-connectivity"
  type        = bool
  default     = true
}