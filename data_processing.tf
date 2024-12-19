provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.example.id

resource "azurerm_databricks_workspace" "example" {
  name                = "databricks-workspace"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "premium"

  tags = {
    environment = "production"
    project     = "vnet-project"
  }
}

resource "azurerm_data_factory" "example" {
  name                = "unique-datafactory-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  identity {
    type = "SystemAssigned"
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "example" {
  name              = "example-blob-storage"
  data_factory_id   = azurerm_data_factory.example.id
  connection_string = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.storage.name};AccountKey=${azurerm_storage_account.storage.primary_access_key};EndpointSuffix=core.windows.net"
}

resource "azurerm_data_factory_dataset_azure_blob" "example" {
  name                   = "example-blob-dataset"
  data_factory_id        = azurerm_data_factory.example.id
  linked_service_name    = azurerm_data_factory_linked_service_azure_blob_storage.example.name
  path                   = "example-folder"
  filename               = "example-file.csv"
}

resource "azurerm_data_factory_pipeline" "example" {
  name            = "example-pipeline"
  data_factory_id = azurerm_data_factory.example.id
  description     = "This pipeline moves and transforms data"

  activities_json = jsonencode([
    {
      "name": "example-copy-activity",
      "type": "Copy",
      "inputs": [
        {
          "name": azurerm_data_factory_dataset_azure_blob.example.name
        }
      ],
      "outputs": [
        {
          "name": "output-dataset"
        }
      ]
    }
  ])
}

resource "databricks_cluster" "example" {
  cluster_name  = "example-cluster"
  spark_version = "7.3.x-scala2.12"
  node_type_id  = "Standard_D3_v2"
  num_workers   = 2
}

resource "databricks_job" "example" {
  name = "example-job"
  new_cluster {
    cluster_name  = "example-cluster"
    spark_version = "7.3.x-scala2.12"
    node_type_id  = "Standard_D3_v2"
    num_workers   = 2
  }
  notebook_task {
    notebook_path = "/Users/your_user_name@example.com/your_notebook"
  }
}

