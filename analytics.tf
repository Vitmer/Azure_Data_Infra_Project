# 33. Synapse Workspace
resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                                 = "synapse-workspace-${random_string.suffix_analytics.result}"
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.data_lake_filesystem.id
  sql_administrator_login              = "adminuser"
  sql_administrator_login_password     = var.synapse_sql_password

  identity {
    type = "SystemAssigned"
  }
}

# 34. Synapse SQL Pool
resource "azurerm_synapse_sql_pool" "sql_pool" {
  name                 = "synapse_sql_pool"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  sku_name             = "DW100c"
}

# 35. RBAC for Synapse
resource "azurerm_role_assignment" "synapse_rbac" {
  principal_id         = var.service_principal_id  
  role_definition_name = "Synapse Administrator"
  scope                = azurerm_synapse_workspace.synapse_workspace.id
}

# 36. Linked Service for Synapse in Data Factory
resource "azurerm_data_factory_linked_service_synapse" "synapse_link" {
  name              = "synapse-linked-service"
  data_factory_id   = azurerm_data_factory.example.id
  connection_string = "Server=tcp:${azurerm_synapse_workspace.synapse_workspace.name}.database.windows.net,1433;Authentication=ActiveDirectoryPassword;"
}

# 37. Dataset for Synapse in Data Factory
resource "azurerm_data_factory_linked_service_sql_server" "example" {
  name              = "sqlserver-link"
  data_factory_id   = azurerm_data_factory.example.id
  connection_string = "Server=tcp:${azurerm_synapse_workspace.synapse_workspace.name}.database.windows.net,1433;Database=etl_db;Authentication=ActiveDirectoryPassword;"
}

# 38. Dataset for SQL Server Table in Azure Data Factory
resource "azurerm_data_factory_dataset_sql_server_table" "analytics_synapse_dataset" {
  name                = "analytics-dataset"
  data_factory_id     = azurerm_data_factory.example.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.example.name
  table_name          = "etl_output_table"
}

# 39. Random Suffix for Unique Naming
resource "random_string" "suffix_analytics" {
  length  = 6
  special = false
  upper   = false
}