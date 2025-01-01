variable "subscription_id" {
  description = "The subscription ID where Azure resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where all resources will reside"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}
variable "service_principal_key" {
  description = "Service principal key for accessing Azure resources"
  type        = string
  sensitive   = true
}
variable "rbac_principal_id" {
  description = "Principal ID for RBAC roles"
  type        = string
}
variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "service_principal_id" {
  description = "Service Principal ID used for RBAC"
  type        = string
}
variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}
variable "data_factory_name" {
  description = "The name of the Azure Data Factory instance"
  type        = string
}
variable "synapse_sql_password" {
  description = "Password for Synapse SQL administrator"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
}

variable "example_secret_value" {
  description = "Value of the example secret"
  type        = string
}

variable "databricks_workspace_name" {
  description = "Name of the Databricks Workspace"
  type        = string
}

