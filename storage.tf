# 10. Storage

# 28. Storage Account with Data Lake Gen2
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "ZRS" #LRS (Locally Redundant Storage), ZRS (Zone Redundant Storage), GRS (Geo-Redundant Storage)
  is_hns_enabled           = true

  lifecycle {
    prevent_destroy = false
  }

  tags = var.tags
}

# 29. Storage Account Network Rules
resource "azurerm_storage_account_network_rules" "network_rules" {
  storage_account_id = azurerm_storage_account.storage.id

  default_action = "Allow" # Temporarily allow access from all addresses

  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = [azurerm_subnet.private.id]

  ip_rules = [] # Specific IPs can be added here if necessary
}

# 30. Storage Container
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

# 32. Data Lake Gen2 Filesystem
resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_filesystem" {
  name               = "datalake-filesystem"
  storage_account_id = azurerm_storage_account.storage.id

  depends_on = [
    azurerm_role_assignment.storage_blob_data_contributor,
    azurerm_role_assignment.storage_account_contributor
  ]

  #depends_on = [azurerm_storage_account.storage]
}

# Папка Raw Data (Сырые данные)
resource "azurerm_storage_data_lake_gen2_path" "raw_data" {
  path               = "raw-data"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.data_lake_filesystem.name
  storage_account_id = azurerm_storage_account.storage.id
  resource           = "directory"
}

# Папка Processed Data (Обработанные данные)
resource "azurerm_storage_data_lake_gen2_path" "processed_data" {
  path               = "processed-data"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.data_lake_filesystem.name
  storage_account_id = azurerm_storage_account.storage.id
  resource           = "directory"
}

# Папка Curated Data (Финальные данные)
resource "azurerm_storage_data_lake_gen2_path" "curated_data" {
  path               = "curated-data"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.data_lake_filesystem.name
  storage_account_id = azurerm_storage_account.storage.id
  resource           = "directory"
}