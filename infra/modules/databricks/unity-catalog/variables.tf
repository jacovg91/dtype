variable "environment" {
  description = "The environment."
  type        = string
}

variable "location" {
  description = "The cloud location."
  type        = string
}

variable "unity_catalog_resource_group_name" {
  description = "The name of the resource group for the UC metastore."
  type        = string
}

variable "common_tags" {
  description = "The default tags to apply to the resource."
  type        = map(string)
  default     = {}
}

variable "databricks_workspace_id" {
  description = "The databricks workspace id."
  type        = string
}

variable "databricks_workspace_url" {
  description = "The databricks workspace url."
  type        = string
}

variable "databricks_account_id" {
  description = "The databricks account id for UC."
  type        = string
}