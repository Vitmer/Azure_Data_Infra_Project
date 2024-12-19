provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.example.id
  azure_client_id             = var.azure_client_id
  azure_client_secret         = var.azure_client_secret
  azure_tenant_id             = var.azure_tenant_id
}

