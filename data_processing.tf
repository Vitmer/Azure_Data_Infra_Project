# 24. Azure Data Factory
resource "azurerm_data_factory" "example" {
  name                = "unique-datafactory-${random_string.suffix_processing.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  identity {
    type = "SystemAssigned"
  }
}

# 25. ETL Pipeline
resource "azurerm_data_factory_pipeline" "etl_pipeline" {
  depends_on = [
    azurerm_data_factory_dataset_azure_blob.example,
    azurerm_data_factory_dataset_sql_server_table.synapse_dataset
  ]

  name            = "etl-pipeline"
  data_factory_id = azurerm_data_factory.example.id

  activities_json = jsonencode([
    {
      "name": "CopyBlobToDataLake",
      "type": "Copy",
      "inputs": [
        {
          "name": azurerm_data_factory_dataset_azure_blob.example.name
        }
      ],
      "outputs": [
        {
          "name": "data-lake-dataset"
        }
      ]
    }
  ])
}

# 26. Databricks ETL Pipeline
resource "azurerm_data_factory_pipeline" "databricks_etl" {
depends_on = [
    azurerm_data_factory_dataset_azure_blob.example,
    azurerm_data_factory_dataset_sql_server_table.synapse_dataset
  ]

  name            = "databricks-etl-pipeline"
  data_factory_id = azurerm_data_factory.example.id

  activities_json = jsonencode([
    {
      "name": "TransformData",
      "type": "DatabricksNotebook",
      "inputs": [
        { "name": "data-lake-dataset" }
      ],
      "outputs": [
        { "name": "synapse-dataset" }
      ],
      "notebook_task": {
        "notebook_path": "/Users/example@databricks.com/ETLNotebook"
      }
    }
  ])
}

# 27. Linked Service for Blob Storage
resource "azurerm_data_factory_linked_service_azure_blob_storage" "blob_service_link" {
  name              = "blob-service-link"
  data_factory_id   = azurerm_data_factory.example.id
  connection_string = azurerm_storage_account.storage.primary_connection_string
}

# 28. Linked Service for Data Lake Gen2
resource "azurerm_data_factory_linked_service_azure_blob_storage" "data_lake_service_link" {
  name              = "data-lake-service-link"
  data_factory_id   = azurerm_data_factory.example.id
  connection_string = azurerm_storage_account.storage.primary_connection_string
}

# 30. Dataset for Synapse SQL Table
resource "azurerm_data_factory_dataset_sql_server_table" "synapse_dataset" {
  name                = "synapse-dataset"
  data_factory_id     = azurerm_data_factory.example.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.example.name
  table_name          = "etl_output_table"
}

# 31. Dataset for Azure Blob
resource "azurerm_data_factory_dataset_azure_blob" "example" {
  name                   = "example-blob-dataset"
  data_factory_id        = azurerm_data_factory.example.id
  linked_service_name    = azurerm_data_factory_linked_service_azure_blob_storage.blob_service_link.name
  path                   = "example-folder/example-file.csv"
}

# 36. Databricks Workspace
resource "azurerm_databricks_workspace" "example" {
  name                = "databricks-workspace"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "premium"

  tags = {
    environment = "production"
    project     = "data-infra-project"
  }
}

# Local variable for using Workspace ID
locals {
  databricks_workspace_id = azurerm_databricks_workspace.example.id
}

# 37. Databricks Cluster
resource "databricks_cluster" "example" {
  depends_on = [azurerm_databricks_workspace.example]

  cluster_name  = "example-cluster"
  spark_version = "11.3.x-scala2.12"
  node_type_id  = "Standard_DS3_v2"
  autoscale {
    min_workers = 2
    max_workers = 8
  }
}

# 38. Random Suffix for Unique Naming
resource "random_string" "suffix_processing" {
  length  = 6
  special = false
  upper   = false
}