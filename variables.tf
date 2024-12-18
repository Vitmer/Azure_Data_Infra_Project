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
  default     = "West Europe"  # Default value if not provided
}

# Storage Account Name
variable "storage_account_name" {
  description = "The name of the storage account. It must be globally unique and adhere to Azure naming conventions"
  type        = string
}

# Additional Tags for Resources
variable "tags" {
  description = "Tags to be applied to all resources for better management and identification"
  type        = map(string)
  default = {
    Environment = "Production"
    Owner       = "Azure Data Infra Project"
  }
}