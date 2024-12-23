# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name       = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    prevent_destroy = false  # Allow deletion of the storage account
  }

  tags = {
    Environment = "Production"
  }
}

# Storage Container Example (optional)
resource "azurerm_storage_container" "data_container" {
  name                  = "data-container"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

# Storage Queue Example (optional)
resource "azurerm_storage_queue" "data_queue" {
  name                 = "dataqueue"
  storage_account_name = azurerm_storage_account.storage.name

  lifecycle {
    prevent_destroy = false  # Allow deletion of the storage queue
  }
}

# Storage Table Example (optional)
resource "azurerm_storage_table" "data_table" {
  name                 = "datatable"
  storage_account_name = azurerm_storage_account.storage.name

  lifecycle {
    prevent_destroy = false  # Allow deletion of the storage table
  }
}

# Optional: Blob Service (if needed)
resource "azurerm_storage_blob" "data_blob" {
  name                   = "data-blob"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.data_container.name
  type                   = "Block"
  source_content         = "Hello, this is a test file!"

  lifecycle {
    prevent_destroy = false  # Allow deletion of the storage blob
  }
}

# Assign RBAC Role to Principal for Storage Account
resource "azurerm_role_assignment" "storage_account_rbac" {
  principal_id         = var.rbac_principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.storage.id
}

resource "azurerm_role_assignment" "blob_contributor" {
  principal_id         = var.rbac_principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_container.data_container.id
}
