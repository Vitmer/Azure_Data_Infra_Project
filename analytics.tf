resource "azurerm_data_factory_linked_service_azure_blob_storage" "synapse_datalake_service" {
  name              = "synapse-datalake-service"
  data_factory_id   = azurerm_data_factory.example.id
  connection_string = azurerm_storage_account.storage.primary_connection_string
}

resource "azurerm_data_factory_dataset_sql_server_table" "synapse_curated_dataset" {
  name                = "synapse-curated-dataset"
  data_factory_id     = azurerm_data_factory.example.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.synapse_datalake_service.name
  table_name          = "curated_data_table"
}

#15. Synapse

# 54. Synapse Workspace
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

# SQL Server (Required for Synapse Data Encryption)
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-server-${random_string.suffix_analytics.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = var.synapse_sql_password
}

# Synapse Data Masking (SQL Server Encryption)
resource "azurerm_mssql_server_transparent_data_encryption" "data_masking" {
  server_id = azurerm_mssql_server.sql_server.id
}

# 55. Synapse SQL Pool
resource "azurerm_synapse_sql_pool" "sql_pool" {
  name                 = "synapse_sql_pool"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  sku_name             = "DW100c"
}

# 56. Synapse Private Link
resource "azurerm_synapse_private_link_hub" "private_link" {
  name                = "synapseprivatelink"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


# 39. Random Suffix for Unique Naming
resource "random_string" "suffix_analytics" {
  length  = 6
  special = false
  upper   = false
}