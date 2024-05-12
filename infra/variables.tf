variable "environment" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "service_principal_name" {
  type = string
}

variable "service_principal_secret" {
  type = string
}

variable "databricks_mounts" {
  type    = set(string)
  default = ["lake"]
}

variable "databricks_account_id" {
  type = string
  default = "e36e9f01-4c96-4512-b368-ccdd3ce548b1"
}