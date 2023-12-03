resource "azurerm_databricks_workspace" "workspace" {
  resource_group_name = var.resource_group_name
  name                = var.databricks_workspace_name
  location            = var.location
  tags                = var.tags

  sku = "premium"

  managed_resource_group_name = var.databricks_workspace_managed_resource_group_name

  # custom_parameters {
  #   no_public_ip = var.databricks_workspace_secure_cluster_connectivity

  #   virtual_network_id                                   = var.virtual_network_id
  #   public_subnet_network_security_group_association_id  = var.private_subnet_id
  #   public_subnet_name                                   = element(split("/", var.private_subnet_id), 10)
  #   private_subnet_network_security_group_association_id = var.public_subnet_id
  #   private_subnet_name                                  = element(split("/", var.public_subnet_id), 10)
  # }
}
