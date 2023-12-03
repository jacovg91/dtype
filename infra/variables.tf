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
  type    = list(string)
  default = ["lake"]
}
