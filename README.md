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

## How to Use
1. **Setup Requirements:**
   - Install Terraform and Azure CLI.
   - Configure an active Azure subscription.
2. **Deployment:**
   - Use the Terraform scripts provided to deploy the infrastructure.
   - Customize configurations based on project requirements.

---

## Technologies Used
- **Azure Services:** Virtual Network, Storage Accounts, Data Factory, Databricks, Synapse Analytics, Azure Bastion, NAT Gateway, Azure Monitor, and Azure Backup.
- **Automation:** Terraform for Infrastructure as Code (IaC).
- **Analytics Tools:** Power BI for visualization and reporting.

---

## License
This project is licensed under the MIT License. Feel free to use and adapt it for your needs.