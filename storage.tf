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

# 15. Data Lake Gen2 Filesystem
resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_filesystem" {
  name               = "datalake-filesystem"
  storage_account_id = azurerm_storage_account.storage.id

  depends_on = [azurerm_storage_account.storage]
}

# 16. Storage Container
resource "azurerm_storage_container" "data_container" {
  name                  = "data-container"
  storage_account_name = var.storage_account_name
  container_access_type = "private"

  depends_on = [azurerm_storage_account.storage]
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
