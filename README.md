
# Azure Infrastructure Project: Comprehensive Deployment Using Terraform

## Overview
This project demonstrates the creation of a fully functional infrastructure in Azure using Terraform, covering key aspects of cloud architecture, network administration, and data engineering. It combines knowledge from three Azure certifications:
- **AZ-900**: Fundamental Azure cloud concepts.
- **AZ-104**: Azure infrastructure and network administration.
- **DP-203**: Data engineering, storage, and analytics.

---

## Key Features

### 1. Infrastructure Deployment
- **Virtual Network (VNet):**
  - Public subnets for NAT Gateway and Bastion.
  - Private subnets for Virtual Machines and data storage.
- **Security and Access:**
  - NAT Gateway for internet access from private subnets.
  - Azure Bastion for secure RDP/SSH access to Virtual Machines.
  - Network Security Groups (NSG) for traffic management.
- **Virtual Machines:**
  - Creation and configuration of VMs with automated backup.

### 2. Data Storage and Management
- **Storage Accounts:**
  - Blob Storage for raw data.
  - Data Lake Storage Gen2 for structured data management.
- **Access Control:**
  - Role-Based Access Control (RBAC) and ACLs for secure data access.
- **Data Lifecycle:**
  - Automated policies for data retention and archiving.

### 3. ETL Processes and Data Processing
- **Azure Data Factory (ADF):**
  - ETL pipelines for data movement and transformation.
- **Azure Databricks:**
  - Big data processing using Spark-based workflows.

### 4. Data Analytics and Visualization
- **Azure Synapse Analytics:**
  - Analytical data warehouse integration with Data Lake Storage.
- **Power BI:**
  - Visualization of analytics and insights.

### 5. Automation and Scalability
- **Terraform Automation:**
  - Deployment and management of all resources.
- **Auto-scaling:**
  - Dynamic scaling of Virtual Machines for optimized performance.

---

## Project Deliverables
- Fully automated Azure infrastructure for networking, storage, and data analytics.
- ETL pipelines leveraging Azure Data Factory and Databricks.
- Analytics-ready data warehouse integrated with Power BI for visualization.
- Terraform scripts for infrastructure deployment and management.

---

## Deployment Order

To ensure successful deployment, resources must be created in the following order. Dependencies between resources are clearly stated:

### Deployment Order with Dependencies

main.tf:

1. Creating Basic Resources

1 azurerm_resource_group.rg 
— create a resource group.
2 data.azurerm_client_config.current 
— fetch the current Azure client configuration.

2. Networking Resources

3 azurerm_virtual_network.vnet 
— create a virtual network.
4 azurerm_subnet.bastion_subnet 
— create a subnet for the Bastion.
5 azurerm_subnet.firewall_subnet 
— create a subnet for the Firewall.
6 azurerm_subnet.gateway_subnet 
— create a subnet for the Gateway.
7 azurerm_subnet.private 
— create a private subnet.
8 azurerm_subnet.public 
— create a public subnet.
9 azurerm_subnet.databricks 
— create a subnet for Databricks.

3. Public IP Addresses

10 azurerm_public_ip.bastion_ip 
— create a Public IP for the Bastion.
11 azurerm_public_ip.firewall_ip 
— create a Public IP for the Firewall.
12 azurerm_public_ip.nat_gateway_ip 
— create a Public IP for the NAT Gateway.
13 azurerm_public_ip.public_vm_ip 
— create a Public IP for the virtual machine.
14 azurerm_public_ip.vpn_gateway_ip 
— create a Public IP for the VPN Gateway.

4. Route Table

15 azurerm_route_table.firewall_route_table 
— create a Route Table for the Firewall.
16 azurerm_subnet_route_table_association.firewall_route_assoc 
— associate the Route Table with the Firewall’s Subnet.

5. NAT Gateway

17 azurerm_nat_gateway.nat_gateway — create a NAT Gateway.
18 azurerm_nat_gateway_public_ip_association.nat_gateway_assoc 
— associate the NAT Gateway with a Public IP.
19 azurerm_subnet_nat_gateway_association.private_nat_assoc 
— associate the NAT Gateway with the private Subnet.
20 azurerm_subnet_nat_gateway_association.databricks_nat_assoc 
— associate the NAT Gateway with the Databricks Subnet.

6. Network Security Group

21 azurerm_network_security_group.nsg_public 
— create an NSG for the public Subnet.
22 azurerm_subnet_network_security_group_association.nsg_public_assoc 
— associate the NSG with the public Subnet.

7. Firewall

23 azurerm_firewall.firewall 
— create a Firewall associated with the Subnet and Public IP.

8. Bastion

24 azurerm_bastion_host.bastion 
— create a Bastion associated with the Subnet and Public IP.

security.tf:

9. Key Vault

25 azurerm_key_vault.key_vault 
— create a Key Vault.
26 azurerm_key_vault_secret.example_secret 
— add secrets to the Key Vault.
27 azurerm_role_assignment.key_vault_reader 
— assign the role for Key Vault access.

storage.tf:

10. Storage

28 azurerm_storage_account.storage 
— create a Storage Account.
29 azurerm_storage_account_network_rules.network_rules 
— configure network rules for the Storage Account.
30 azurerm_storage_container.data_container 
— create a container in the Storage Account.
31 azurerm_storage_blob.data_blob 
— upload Blob data.
32 azurerm_storage_data_lake_gen2_filesystem.data_lake_filesystem 
— create a Data Lake filesystem.

main.tf:

11. Private DNS

33 azurerm_private_dns_zone.dns_zone 
— create a Private DNS zone.
34 azurerm_private_dns_zone_virtual_network_link.dns_link 
— link the DNS zone to the virtual network.
35 azurerm_private_endpoint.storage_private_link 
— create a Private Endpoint for the storage.

monitoring.tf:

12. Monitoring

36 azurerm_log_analytics_workspace.logs 
— create a Log Analytics Workspace.
37 azurerm_monitor_action_group.email_alerts 
— configure an Action Group for alerts.
38 azurerm_monitor_diagnostic_setting.data_factory_logs 
— enable logging for Data Factory.
39 azurerm_monitor_diagnostic_setting.databricks_logs 
— enable logging for Databricks.
40 azurerm_monitor_diagnostic_setting.vnet_logs 
— enable logging for the VNet.
41 azurerm_monitor_metric_alert.private_vm_cpu_alert 
— configure a CPU alert for the private VM.
42 azurerm_monitor_metric_alert.public_vm_cpu_alert 
— configure a CPU alert for the public VM.

data_processing.tf

13. Data Factory

43 azurerm_data_factory.example 
— create a Data Factory.
44 azurerm_data_factory_pipeline.etl_pipeline 
— create an ETL pipeline.
45 azurerm_data_factory_pipeline.databricks_etl 
— create a Databricks ETL pipeline.
46 azurerm_data_factory_dataset_azure_blob.example 
— create a Dataset for Azure Blob.
47 azurerm_data_factory_dataset_sql_server_table.analytics_synapse_dataset 
— create a Dataset for Synapse analytics.
48 azurerm_data_factory_dataset_sql_server_table.synapse_dataset 
— create a Dataset for Synapse.
49 azurerm_data_factory_linked_service_azure_blob_storage.blob_service_link 
— configure a linked service for Azure Blob.
50 azurerm_data_factory_linked_service_azure_blob_storage.data_lake_service_link 
— configure a linked service for Data Lake.
51 azurerm_data_factory_linked_service_sql_server.example 
— configure a linked service for SQL Server.
52 azurerm_data_factory_linked_service_synapse.synapse_link 
— configure a linked service for Synapse.

14. Databricks

53 azurerm_databricks_workspace.example 
— create a Databricks Workspace.

analytics.tf:

15. Synapse

54 azurerm_synapse_workspace.synapse_workspace 
— create a Synapse Workspace.
55 azurerm_synapse_sql_pool.sql_pool 
— create a Synapse SQL Pool.
56 azurerm_synapse_private_link_hub.private_link 
— configure Private Link for Synapse.

main.tf:

16. Virtual Machines

57 azurerm_linux_virtual_machine.private_vm 
— create a private VM.
58 azurerm_linux_virtual_machine.public_vm 
— create a public VM.
59 azurerm_backup_policy_vm.vm_backup_policy 
— create a backup policy for VMs.
60 azurerm_backup_protected_vm.protected_vm_private 
— protect the private VM.
61 azurerm_backup_protected_vm.protected_vm_public 
— protect the public VM.


---

## How to Use
1. **Setup Requirements:**
   - Install Terraform and Azure CLI.
   - Configure an active Azure subscription.
2. **Deployment:**
   - Use the Terraform scripts provided to deploy the infrastructure in the specified order.
3. **Commands:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
---

## Technologies Used
- **Azure Services:** Virtual Network, Storage Accounts, Data Factory, Databricks, Synapse Analytics, Azure Bastion, NAT Gateway, Azure Monitor, and Azure Backup.
- **Automation:** Terraform for Infrastructure as Code (IaC).
- **Analytics Tools:** Power BI for visualization and reporting.

---

## License
This project is licensed under the MIT License. Feel free to use and adapt it for your needs.