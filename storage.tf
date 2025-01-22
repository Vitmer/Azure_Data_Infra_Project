# 14. Storage Account with Data Lake Gen2
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  lifecycle {
    prevent_destroy = false
  }

  tags = var.tags
}

# Assign 'Storage Blob Data Contributor' role to the Service Principal
resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.service_principal_id
}

# Assign 'Storage Account Contributor' role to the Service Principal
resource "azurerm_role_assignment" "storage_account_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = var.service_principal_id
}

# Storage Account Network Rules
resource "azurerm_storage_account_network_rules" "network_rules" {
  storage_account_id = azurerm_storage_account.storage.id

  default_action = "Allow" # Temporarily allow access from all addresses

  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = [azurerm_subnet.private.id]

  ip_rules = [] # Specific IPs can be added here if necessary
}

# 15. Data Lake Gen2 Filesystem
resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_filesystem" {
  name               = "datalake-filesystem"
  storage_account_id = azurerm_storage_account.storage.id

  depends_on = [
    azurerm_role_assignment.storage_blob_data_contributor,
    azurerm_role_assignment.storage_account_contributor
  ]

  #depends_on = [azurerm_storage_account.storage]
}

# 16. Storage Container
resource "azurerm_storage_container" "data_container" {
  name                  = "data-container"
  storage_account_name = var.storage_account_name
  container_access_type = "private"

  depends_on = [
    azurerm_role_assignment.storage_blob_data_contributor,
    azurerm_role_assignment.storage_account_contributor
  ]
  #depends_on = [azurerm_storage_account.storage]
}

# 17. Blob Storage
resource "azurerm_storage_blob" "data_blob" {
  name                   = "data-blob"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.data_container.name
  type                   = "Block"
  source_content         = "Hello, this is a test file!"

  depends_on = [azurerm_storage_container.data_container]
}
