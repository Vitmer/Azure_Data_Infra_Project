# Synapse Workspace
resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                                 = "synapse-workspace"
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_container.data_container.id
  sql_administrator_login              = "adminuser"
  sql_administrator_login_password     = var.synapse_sql_password

  identity {
    type = "SystemAssigned"
  }
}

# Synapse SQL Pool
resource "azurerm_synapse_sql_pool" "sql_pool" {
  name                 = "synapse_sql_pool" # Имя без дефисов
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  sku_name             = "DW100c"
  storage_account_type = "GRS"
}

# RBAC for Synapse
resource "azurerm_role_assignment" "synapse_rbac" {
  principal_id         = var.rbac_principal_id
  role_definition_name = "Synapse Administrator"
  scope                = azurerm_synapse_workspace.synapse_workspace.id
}