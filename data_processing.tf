resource "azurerm_data_factory_linked_service_web" "source_api" {
  name            = "source-api-link"
  data_factory_id = azurerm_data_factory.example.id

  url                 = "https://example.com/api/data" # Specify the API URL here
  authentication_type = "Basic" 
}

resource "azurerm_data_factory_dataset_http" "source_api_dataset" {
  name                = "source-api-dataset"
  data_factory_id     = azurerm_data_factory.example.id
  linked_service_name = azurerm_data_factory_linked_service_web.source_api.name

  request_method = "GET" # Use the GET method if the API simply returns data
  relative_url   = "/latest" # If the API supports versions or different endpoints
}

# 13. Data Factory

# 43. Azure Data Factory
resource "azurerm_data_factory" "example" {
  name                = "unique-datafactory-${random_string.suffix_processing.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  identity {
    type = "SystemAssigned"
  }
}

# Dataset для Raw Data (Azure Data Factory)
resource "azurerm_data_factory_dataset_azure_blob" "datalake_raw_dataset" {
  name                = "data-lake-raw-dataset" 
  data_factory_id     = azurerm_data_factory.example.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.data_lake_service_link.name
  path                = "datalake-filesystem/raw-data/"
}

# Dataset для Processed Data
resource "azurerm_data_factory_dataset_azure_blob" "datalake_processed_dataset" {
  name                = "data-lake-processed-dataset"  
  data_factory_id     = azurerm_data_factory.example.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.data_lake_service_link.name
  path                = "datalake-filesystem/processed-data/"
}

# Dataset для Curated Data
resource "azurerm_data_factory_dataset_azure_blob" "datalake_curated_dataset" {
  name                = "data-lake-curated-dataset" 
  data_factory_id     = azurerm_data_factory.example.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.data_lake_service_link.name
  path                = "datalake-filesystem/curated-data/"
}

# 44. ETL Pipeline
resource "azurerm_data_factory_pipeline" "etl_pipeline" {
  depends_on = [
    azurerm_data_factory_dataset_azure_blob.datalake_raw_dataset
  ]

  name            = "etl-pipeline"
  data_factory_id = azurerm_data_factory.example.id

  activities_json = jsonencode([
    {
      "name": "CopyBlobToRawData",
      "type": "Copy",
      "inputs": [
        { "name": azurerm_data_factory_dataset_http.source_api_dataset.name }
      ],
      "outputs": [
        { "name": azurerm_data_factory_dataset_azure_blob.datalake_raw_dataset.name }
      ]
    },
    {
      "name": "TransformRawToProcessed",
      "type": "DatabricksNotebook",
      "inputs": [
        { "name": azurerm_data_factory_dataset_azure_blob.datalake_raw_dataset.name }
      ],
      "outputs": [
        { "name": azurerm_data_factory_dataset_azure_blob.datalake_processed_dataset.name }
      ],
      "notebook_task": {
        "notebook_path": "/Users/example@databricks.com/CleaningNotebook"
      }
    },
    {
      "name": "TransformProcessedToCurated",
      "type": "DatabricksNotebook",
      "inputs": [
        { "name": azurerm_data_factory_dataset_azure_blob.datalake_processed_dataset.name }
      ],
      "outputs": [
        { "name": azurerm_data_factory_dataset_azure_blob.datalake_curated_dataset.name }
      ],
      "notebook_task": {
        "notebook_path": "/Users/example@databricks.com/AggregationNotebook"
      }
    }
  ])
}

# 45. Databricks ETL Pipeline
resource "azurerm_data_factory_pipeline" "databricks_etl_cleaning" {
  depends_on = [
    azurerm_data_factory_dataset_azure_blob.datalake_raw_dataset 
  ]

  name            = "databricks-etl-cleaning"
  data_factory_id = azurerm_data_factory.example.id

  activities_json = jsonencode([
    {
      "name": "TransformRawToProcessed",
      "type": "DatabricksNotebook",
      "inputs": [
        { "name": "data-lake-raw-dataset" }  
      ],
      "outputs": [
        { "name": "data-lake-processed-dataset" }  
      ],
      "notebook_task": {
        "notebook_path": "/Users/example@databricks.com/CleaningNotebook"
      }
    }
  ])
}

resource "azurerm_data_factory_pipeline" "databricks_etl_aggregation" {
  depends_on = [
    azurerm_data_factory_dataset_azure_blob.datalake_processed_dataset  
  ]

  name            = "databricks-etl-aggregation"
  data_factory_id = azurerm_data_factory.example.id

  activities_json = jsonencode([
    {
      "name": "TransformProcessedToCurated",
      "type": "DatabricksNotebook",
      "inputs": [
        { "name": "data-lake-processed-dataset" }  
      ],
      "outputs": [
        { "name": "synapse-dataset" } 
      ],
      "notebook_task": {
        "notebook_path": "/Users/example@databricks.com/AggregationNotebook"
      }
    }
  ])
}

# 48. Dataset for Synapse SQL Table
resource "azurerm_data_factory_dataset_sql_server_table" "synapse_dataset" {
  name                = "synapse-dataset"
  data_factory_id     = azurerm_data_factory.example.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.example.name
  table_name          = "etl_output_table"
}

# 49. Linked Service for Blob Storage
resource "azurerm_data_factory_linked_service_azure_blob_storage" "blob_service_link" {
  name              = "blob-service-link"
  data_factory_id   = azurerm_data_factory.example.id
  connection_string = azurerm_storage_account.storage.primary_connection_string
}

# 50. Linked Service for Data Lake Gen2
resource "azurerm_data_factory_linked_service_azure_blob_storage" "data_lake_service_link" {
  name              = "data-lake-service-link"
  data_factory_id   = azurerm_data_factory.example.id
  connection_string = azurerm_storage_account.storage.primary_connection_string
}

# 51. Dataset for Synapse in Data Factory
resource "azurerm_data_factory_linked_service_sql_server" "example" {
  name              = "sqlserver-link"
  data_factory_id   = azurerm_data_factory.example.id
  connection_string = "Server=tcp:${azurerm_mssql_server.sql_server.name}.database.windows.net,1433;Database=etl_db;Authentication=ActiveDirectoryPassword;"
}

# 52. Linked Service for Synapse in Data Factory
resource "azurerm_data_factory_linked_service_synapse" "synapse_link" {
  name              = "synapse-linked-service"
  data_factory_id   = azurerm_data_factory.example.id
  connection_string = "Server=tcp:${azurerm_mssql_server.sql_server.name}.database.windows.net,1433;Authentication=ActiveDirectoryPassword;"
}

# 14. Databricks

# 53. Databricks Workspace
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

# Output for the Databricks Workspace URL
output "databricks_workspace_url" {
  value       = "https://${azurerm_databricks_workspace.example.workspace_url}"
  description = "URL of the created Databricks Workspace"
}

# null_resource to add admin principal
resource "null_resource" "add_principal_to_admins" {
  depends_on = [azurerm_databricks_workspace.example]

  provisioner "local-exec" {
    command = <<EOT
      set -euo pipefail

      # Maximum retry attempts
      MAX_RETRIES=10
      RETRY_DELAY=10

      # Wait for the Databricks Workspace URL to be available
      for i in $(seq 1 $MAX_RETRIES); do
        WORKSPACE_URL=$(terraform output -raw databricks_workspace_url || echo "")

        if [ -n "$WORKSPACE_URL" ] && [ "$WORKSPACE_URL" != "0" ]; then
          echo "Databricks Workspace URL is available: $WORKSPACE_URL"
          break
        fi

        echo "Databricks Workspace URL is not available, attempt $i/$MAX_RETRIES..."
        sleep $RETRY_DELAY

        if [ $i -eq $MAX_RETRIES ]; then
          echo "Exceeded maximum retry attempts for Databricks Workspace URL." >&2
          exit 1
        fi
      done

      # Retrieve Azure access token
      TOKEN=$(az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query accessToken -o tsv)

      if [ -z "$TOKEN" ]; then
        echo "Failed to retrieve access token." >&2
        exit 1
      fi

      # Send API request to add admin principal
      for i in $(seq 1 $MAX_RETRIES); do
        curl -X POST -H "Authorization: Bearer $TOKEN" \
             -H "Content-Type: application/json" \
             -d '{
               "schemas": ["urn:ietf:params:scim:schemas:core:2.0:Group"],
               "displayName": "admins",
               "members": [
                 {
                   "value": "${var.service_principal_id}",
                   "type": "ServicePrincipal"
                 }
               ]
             }' \
             "$WORKSPACE_URL/api/2.0/preview/scim/v2/Groups" && break || {
          echo "Error adding admin principal, retrying attempt $i/$MAX_RETRIES..."
          sleep $RETRY_DELAY
        }

        if [ $i -eq $MAX_RETRIES ]; then
          echo "Failed to add admin principal after $MAX_RETRIES attempts." >&2
          exit 1
        fi
      done
    EOT
    interpreter = ["bash", "-c"]
  }
}

# null_resource to create Databricks Cluster
resource "null_resource" "create_databricks_cluster" {
  depends_on = [null_resource.add_principal_to_admins]

  provisioner "local-exec" {
    command = <<EOT
      set -euo pipefail

      WORKSPACE_URL=$(terraform output -raw databricks_workspace_url)

      if [ -z "$WORKSPACE_URL" ]; then
        echo "Databricks Workspace URL is not found." >&2
        exit 1
      fi

      TOKEN=$(az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query accessToken -o tsv)

      if [ -z "$TOKEN" ]; then
        echo "Failed to retrieve access token." >&2
        exit 1
      fi

      # Send API request to create the cluster
      for i in $(seq 1 5); do
        curl -X POST -H "Authorization: Bearer $TOKEN" \
             -H "Content-Type: application/json" \
             -d '{
               "cluster_name": "example-cluster",
               "spark_version": "11.3.x-scala2.12",
               "node_type_id": "Standard_DS3_v2",
               "autoscale": {
                 "min_workers": 2,
                 "max_workers": 8
               }
             }' \
             "$WORKSPACE_URL/api/2.0/clusters/create" && break || {
          echo "Error creating cluster, retrying attempt $i/5..."
          sleep 10
        }

        if [ $i -eq 5 ]; then
          echo "Failed to create cluster after 5 attempts." >&2
          exit 1
        fi
      done
    EOT
    interpreter = ["bash", "-c"]
  }
}

# Random Suffix for Unique Naming
resource "random_string" "suffix_processing" {
  length  = 6
  special = false
  upper   = false
}
