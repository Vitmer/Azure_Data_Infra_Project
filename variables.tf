# Azure Subscription ID
variable "subscription_id" {
  description = "The subscription ID where Azure resources will be deployed"
  type        = string
}

# Resource Group Name
variable "resource_group_name" {
  description = "The name of the resource group where all resources will reside"
  type        = string
}

# Azure Region
variable "location" {
  description = "The Azure region where resources will be created (e.g., 'West Europe')"
  type        = string
  default     = "West Europe"
}

# Storage Account Name
variable "storage_account_name" {
  description = "The name of the storage account. It must be globally unique and adhere to Azure naming conventions"
  type        = string
}

# Tags for Resources
variable "tags" {
  description = "Tags to be applied to all resources for better management and identification"
  type        = map(string)
  default = {
    Environment = "Production"
    Owner       = "Azure Data Infra Project"
  }
}

# Databricks Workspace Name
variable "databricks_workspace_name" {
  description = "The name of the Databricks workspace"
  type        = string
  default     = "databricks-workspace"
}

# Data Factory Name
variable "data_factory_name" {
  description = "The name of the Data Factory"
  type        = string
  default     = "MerenicsDataFactory"
}

# Azure Client ID (for Databricks Provider)
variable "azure_client_id" {
  description = "Azure Client ID for Databricks API authentication"
  type        = string
}

# Azure Client Secret (for Databricks Provider)
variable "azure_client_secret" {
  description = "Azure Client Secret for Databricks API authentication"
  type        = string
  sensitive   = true
}

# Azure Tenant ID (for Databricks Provider)
variable "azure_tenant_id" {
  description = "Azure Tenant ID for Databricks API authentication"
  type        = string
}

# Additional Databricks Configuration
variable "databricks_sku" {
  description = "SKU for Databricks workspace (e.g., 'standard' or 'premium')"
  type        = string
  default     = "standard"
}

# Address Prefix for Databricks Subnet
variable "databricks_subnet_prefix" {
  description = "Address prefix for Databricks subnet"
  type        = string
  default     = "10.0.4.0/24"
}

# Default Address Prefixes for VNet
variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}