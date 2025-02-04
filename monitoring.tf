# 12. Monitoring

# 36. Log Analytics Workspace for diagnostics
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "log-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 37. Monitor Action Group
resource "azurerm_monitor_action_group" "email_alerts" {
  name                = "email-alerts"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "alerts"

  email_receiver {
    name          = "AdminEmail"
    email_address = "admin@example.com"
  }
}

# 38. Monitor ADF Diagnostics
resource "azurerm_monitor_diagnostic_setting" "data_factory_logs" {
  name                       = "adf-logs"
  target_resource_id         = azurerm_data_factory.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  enabled_log {
    category = "PipelineRuns"
  }

  enabled_log {
    category = "ActivityRuns"
  }
}

# 39. Databricks к Log Analytics Workspace
resource "azurerm_monitor_diagnostic_setting" "databricks_logs" {
  name               = "databricks-logs"
  target_resource_id         = azurerm_databricks_workspace.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  enabled_log {
    category = "clusters"
  }

  enabled_log {
    category = "jobs"
  }

  enabled_log {
    category = "notebook"
  }

  enabled_log {
    category = "dbfs"
  }

  enabled_log {
    category = "workspace"
  }
}

# 40. Enable logging for the VNet.
resource "azurerm_monitor_diagnostic_setting" "vnet_logs" {
  name                       = "vnet-diagnostics"
  target_resource_id         = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# 41. Alert for high CPU usage on private VM
resource "azurerm_monitor_metric_alert" "private_vm_cpu_alert" {
  name                = "cpu-alert-private-vm"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_virtual_machine.private_vm.id]
  description         = "Alert for high CPU usage on private VM"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

# 42. Alert for high CPU usage on public VM
resource "azurerm_monitor_metric_alert" "public_vm_cpu_alert" {
  name                = "cpu-alert-public-vm"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_virtual_machine_scale_set.public_vmss.id]
  description         = "Alert for high CPU usage on public VM"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

# Enable logging for firewall
resource "azurerm_monitor_diagnostic_setting" "firewall_logs" {
  name                        = "Firewall-Logging"
  target_resource_id          = azurerm_firewall.firewall.id
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.logs.id

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }
}