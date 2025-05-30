## 🧱 Architecture Summary

This project delivers a secure, scalable **3-tier cloud architecture** on Microsoft Azure, fully provisioned through **modular Terraform code** and maintained through a secure **CI/CD pipeline in Azure DevOps**. It follows security best practices based on **Zero Trust principles**, offering end-to-end protection for web applications, workloads, and data.

---

### 🧩 3-Tier Model

- **Web Tier**:
  - Exposed via a **Public IP** connected to an **Azure Application Gateway with WAF (Web Application Firewall)**.
  - Responsible for routing HTTP/HTTPS traffic securely to backend services while applying OWASP security rules.

- **App Tier**:
  - Hosted on **Azure Kubernetes Service (AKS)** integrated with **Azure CNI** for subnet-level network control.
  - Uses **Workload Identity** to access Azure resources securely without credentials.
  - Supports microservices and containerized workloads with built-in scalability.

- **Data Tier**:
  - Comprised of **private Azure storage or database services**.
  - Access is limited to internal subnets using **Private Endpoints** and DNS zone integrations.

---

### 🛠️ Tooling

- **Terraform**: Automates infrastructure provisioning using reusable modules for VNet, AKS, WAF, Key Vault, etc.
- **Azure DevOps**: Manages CI/CD pipelines for Terraform with secure backend, linting, and approval workflows.
- **tfsec**: Integrates static code analysis into the pipeline to catch misconfigurations before deployment.
- **Microsoft Defender for Cloud**: Provides CSPM, threat detection, and secure configuration recommendations.
- **Microsoft Sentinel**: Offers SIEM capabilities, alerting, and integration with Logic Apps for incident response.
- **Azure Logic Apps**: Automates security response (e.g., email alerts on incidents triggered by Sentinel rules).

---

### 🛡️ Security Features

- **Network Segmentation**:
  - Uses **NSGs (Network Security Groups)** and **UDRs (User Defined Routes)** to isolate web, app, and data tiers.
  - Traffic from app and data tiers is routed through an **Azure Firewall** for inspection and logging.

- **Private Endpoints**:
  - Key Vault, storage, and database resources are accessible only through private IPs within the VNet.
  - **Private DNS zones** configured to support name resolution for private resources.

- **Azure Firewall**:
  - Deployed as a centralized egress control point.
  - Logs and monitors outbound traffic from app and data subnets.

- **Microsoft Sentinel + Logic App**:
  - Sentinel detects security events (e.g., Key Vault deletion).
  - Logic App automates incident responses such as email alerts or ticket creation.

- **Identity and Access Management**:
  - RBAC roles assigned via Terraform to enforce least privilege.
  - AKS workloads use **federated Workload Identity** to access Key Vault securely.
  - No hardcoded secrets or access policies used; everything managed via **Entra ID + Terraform**.

---

This architecture is built to be **highly secure**, **modular**, and **production-grade**, supporting modern DevSecOps practices and ready for enterprise deployment.


## 📂 Folder Structure

```bash
.
├── environments/
│   ├── dev/
│   │   └── main.tf
│   └── prod/
├── modules/
│   ├── networking/
│   ├── waf/
│   ├── keyvault/
│   ├── sentinel/
│   ├── simulations/
│   ├── firewall/
│   ├── defender/
│   ├── aks/
│   ├── logicapp/
│   └── policy/
└── azure-pipelines.yml

``` 
---

<p align="center">
  <img src="https://github.com/poohb0321/azure-3tier-secure-infra/blob/af432222509b8932dd8e1ef3d7cbb9761b5656cf/images/Screenshot%202025-05-30%20130104.png" width="450" alt="Architecture diagram">
</p>

---
# ⚙️ Terraform Modules – Detailed Implementation

This document explains the purpose, functionality, and security considerations for each Terraform module used in the 3-Tier Secure Azure Architecture project.

---

## 1. `networking`

**Purpose**: Sets up the foundational network infrastructure.

**Components**:
- Virtual Network (VNet)
- Subnets: `web`, `app`, and `db`
- Network Security Groups (NSGs) with inbound/outbound rules
- User Defined Routes (UDRs) to control traffic flow

**Security Features**:
- NSG rules deny public traffic to app and db subnets
- UDR routes funnel egress traffic via Azure Firewall

## 1. `networking` – Virtual Network Foundation

### 🧩 Purpose

Establishes the **core virtual network infrastructure** necessary for secure, segmented communication across the 3-tier architecture (web, app, and db layers). Provides the base for secure routing and traffic inspection.

---

### 🔧 Components

- **Virtual Network (VNet)** – Central network with custom address space.
- **Subnets** – Logical segmentation:
  - `web-subnet` – Exposed to the Application Gateway (WAF)
  - `app-subnet` – Hosts AKS or app services
  - `db-subnet` – Isolated subnet for private storage or databases
- **Network Security Groups (NSGs)** – Attached to each subnet with defined allow/deny rules
- **User Defined Routes (UDRs)** – Custom route tables for directing outbound traffic via Azure Firewall

---

### 🔐 Security Features

- **Subnet Isolation**: Web tier is public-facing, while app and db tiers are private and protected by NSGs.
- **NSG Rules**:
  - Deny all inbound traffic by default
  - Allow specific ports (e.g., HTTP from WAF to app)
- **UDR Enforcement**:
  - All outbound traffic from app and db subnets routed through Azure Firewall
  - Prevents direct internet access

---
<p float="center">
  <img src="https://github.com/poohb0321/azure-3tier-secure-infra/blob/044e784ace7e282060b611634bac73500d9a6073/images/Screenshot%202025-05-27%20235511.png" width="450" alt="imag5">
<img src="https://github.com/poohb0321/azure-3tier-secure-infra/blob/5dcdf2ee6f8106ce804b8bac234ab5aafa4a4642/images/3tier-architecture.png" width="450" alt="imag6">
</p>
<img src="https://github.com/poohb0321/azure-3tier-secure-infra/blob/5564d9b97fc53db565b33ae3f9fb7f8f79c32217/images/Screenshot%202025-05-27%20235901.png" width="450" alt="imag4">
</p>


---

### ✅ Key Benefits

- Enforces **Zero Trust** principles with layered segmentation
- Enables centralized traffic inspection and control
- Easily reusable across environments (dev, prod)

---

## 2. `waf`

**Purpose**: Deploys an Application Gateway WAF for the web tier.

**Components**:
- Azure Application Gateway with WAF_v2 SKU
- Frontend IP (Public)
- Backend pool and HTTP settings
- Listener and routing rules

**Security Features**:
- OWASP rules enabled for Layer 7 protection
- Blocks malicious traffic to web apps

### 🧩 Purpose

Deploys a **Layer 7 Application Gateway with Web Application Firewall (WAF)** to protect the web tier from common web attacks and serve as the frontend entry point to the infrastructure.

---

### 🔧 Components

- **Azure Application Gateway** using `WAF_v2` SKU
- **Public IP** for frontend access to web applications
- **Frontend Configuration**:
  - Listener on port 80/443
  - Frontend IP mapped to the public IP
- **Backend Pool**:
  - Points to internal services (e.g., AKS Ingress or App Service)
- **HTTP Settings**:
  - Timeout, protocol, port settings for backend communication
- **Routing Rules**:
  - URL-based routing, multi-site hosting (if needed)

---

### 🔐 Security Features

- **WAF Enabled** with OWASP Core Rule Set (CRS)
  - Protects against SQL injection, XSS, CSRF, Remote File Inclusion, etc.
- **SSL Termination** (configurable)
  - Decrypts traffic for inspection
- **IP Whitelisting/Geo-blocking** (extendable)
  - Rules can be created to allow/deny based on IP or region
- **End-to-End TLS** (optional)
  - Allows encrypted communication to the backend as well

---
<p float="center">
  <img src="https://github.com/poohb0321/azure-3tier-secure-infra/blob/044e784ace7e282060b611634bac73500d9a6073/images/Screenshot%202025-05-27%20235618.png" width="450" alt="imag2">
<img src="https://github.com/poohb0321/azure-3tier-secure-infra/blob/044e784ace7e282060b611634bac73500d9a6073/images/Screenshot%202025-05-27%20235511.png" width="450" alt="imag3">
</p>
---

### ✅ Key Benefits

- Provides **centralized Layer 7 protection** for public-facing services
- Acts as an **intelligent reverse proxy** with routing and SSL support
- **Scalable and secure** entry point with customizable WAF rules

---

## 3. `firewall` – Azure Firewall for Centralized Egress Control

### 🧩 Purpose

Implements **Azure Firewall** to enforce centralized outbound traffic control, enable deep packet inspection, and collect diagnostic logs for auditing and compliance. It acts as a security gateway for all egress traffic from private subnets.

---

### 🔧 Components

- **Azure Firewall**:
  - Deployed in a dedicated `AzureFirewallSubnet`
  - Configured with its own public IP
- **Route Tables (UDRs)**:
  - Applied to `app` and `db` subnets
  - Forces all egress traffic through the Azure Firewall
- **Diagnostic Settings**:
  - Logs sent to Log Analytics or Storage for auditing
- **Firewall Rules (optional extension)**:
  - Application rules: FQDN-based access control
  - Network rules: IP/protocol-based rules

---

### 🔐 Security Features

- **Choke Point Design**:
  - All traffic exits through a single inspection point
- **Traffic Logging**:
  - Logs every allowed and denied connection for audit and forensic purposes
- **Custom Rule Enforcement**:
  - Block traffic to disallowed domains or services
- **Supports Threat Intelligence**:
  - Can alert or block known malicious IPs using Microsoft threat feeds

---

### 📸 Recommended Screenshots

| Screenshot                              | Description                                                    |
|-----------------------------------------|----------------------------------------------------------------|
| **Azure Firewall Overview**             | Basic info + public IP address                                 |
| **Route Table View (UDR)**              | UDR for app/db subnet pointing to Azure Firewall               |
| **Diagnostic Settings**                 | Configured to send logs to Log Analytics or Sentinel workspace |

---

### ✅ Key Benefits

- **Centralized egress filtering** to reduce attack surface
- **Enhanced visibility** into outbound traffic patterns
- Easily extendable with **advanced rule sets** and **TLS inspection**

---

## 4. `aks` – Azure Kubernetes Service (App Tier Deployment)

### 🧩 Purpose

Deploys the **application layer** using **Azure Kubernetes Service (AKS)**, enabling containerized workloads with scalable orchestration. The module is enhanced with **Azure CNI** for subnet-level integration and **Workload Identity** for secure identity and secret management.

---

### 🔧 Components

- **AKS Cluster**:
  - Deployed with **Azure CNI** for full VNet integration
  - Configured to run in the `app-subnet`
- **Workload Identity Integration**:
  - Enables Kubernetes workloads to securely access Azure resources without secrets
- **Node Pools** (optional):
  - Custom configurations for system and user workloads
- **Network Policy**:
  - Implements traffic control between pods and namespaces

---

### 🔐 Security Features

- **Workload Identity**:
  - Eliminates the use of Kubernetes-managed identities or secrets
  - Assigns Azure roles to workloads via federated identity
- **Pod-level Network Policies**:
  - Enforce allow/deny rules at pod or namespace level
  - Prevents lateral movement within the cluster
- **Private Cluster Configuration** (extendable):
  - Disables public API server access (optional security hardening)
- **Defender for Containers Integration**:
  - Provides real-time threat detection, vulnerability scanning, and compliance posture

---

### 📸 Recommended Screenshots

| Screenshot                               | Description                                                      |
|------------------------------------------|------------------------------------------------------------------|
| **AKS Cluster Overview**                 | Portal view showing version, node pools, and networking config  |
| **Workload Identity Setup**              | Azure AD app registration and federated credential screenshot   |
| **Pod Security Policies / Network Policy**| Applied rules to limit pod-to-pod or pod-to-external traffic    |
| **Defender for Containers Dashboard**    | Alerts and vulnerabilities tied to AKS workloads                |

---

### ✅ Key Benefits

- **Secure Identity Access** with federated Workload Identity
- **Scalable container orchestration** with pod-level access control
- Fully integrated with Azure VNet and **Defender for Containers**
- Enforces **Zero Trust within the cluster**

---

## 5. `keyvault` – Secure Secrets and Key Management

### 🧩 Purpose

Deploys **Azure Key Vault** to centrally manage application secrets, certificates, and encryption keys with secure access controls. Integrated with Sentinel and Logic App for monitoring and alert automation.

---

### 🔧 Components

- **Azure Key Vault**:
  - Created with standard SKU (or premium if needed for HSM-backed keys)
  - Region and naming driven by variables
- **Access Control**:
  - Managed using **RBAC**, not access policies (recommended approach)
- **Private Endpoint Support** (optional):
  - Can be extended to restrict access via Private Link
- **Terraform Role Assignments**:
  - Automatically grants appropriate roles to AKS and other modules

---

### 🔐 Security Features

- **RBAC-Based Access**:
  - Fine-grained role assignments (e.g., `Reader`, `Key Vault Secrets User`, etc.)
  - No static secrets or access policies
- **Logic App Integration**:
  - Triggers alerts when secrets are accessed or deleted
- **Microsoft Sentinel Integration**:
  - Monitors Key Vault logs for anomalous activities
- **Private Access Option**:
  - Prevents exposure of secrets over public endpoints (if enabled)

---

### 📸 Recommended Screenshots

| Screenshot                             | Description                                                  |
|----------------------------------------|--------------------------------------------------------------|
| **Key Vault Overview**                 | Portal view showing vault settings and access configuration |
| **IAM Role Assignments**               | List of assigned identities (AKS, users, Logic App, etc.)    |
| **Activity Logs in Sentinel**          | Example alert for secret read/delete activity                |
| **Logic App Triggered by Vault Access**| Workflow run history showing triggered action                |

---

### ✅ Key Benefits

- Centralized and **secure storage** for secrets and keys
- **No manual role assignments** – managed via Terraform
- Supports alerting via **Sentinel + Logic App**
- Easily extendable for **Private Endpoint** and **Key Rotation**

---


## 6. `sentinel`

**Purpose**: Implements SIEM capabilities using Microsoft Sentinel.

**Components**:
- Log Analytics Workspace
- Microsoft Sentinel Workspace
- Data connectors (Activity Logs, Defender, etc.)
- Alert Rules

**Security Features**:
- Monitors security events and resources
- Sends alerts to Logic App for remediation

### 🔗 Data Connectors

- Connected to the following:
  - **Azure Activity Logs**
  - **Microsoft Defender for Cloud**
  - **Azure AD Sign-in Logs** (optional)

### 🚨 Alert Rules

- Custom **Analytics Rules** created to detect:
  - Key Vault access/deletion
  - Suspicious login patterns
  - Defender security alerts

### 🔄 Logic App Integration

- Sentinel alerts trigger Logic Apps for automated response.
- Alerts flow: **Sentinel → Alert → Playbook → Email/SOC Notification**

> 📸 **Recommended Screenshot**: Sentinel → Incidents tab + Analytics Rules tab.

---

## 🧾 Azure Policies (Policy-as-Code)

### ✅ Policies Assigned

- **Deny RDP from Internet** – Prevents RDP access on public IPs
- **Deny SSH from Internet** – Blocks SSH on exposed resources
- **Deny Public IP Creation** – Enforces private infrastructure
- **Audit HTTPS on Storage Accounts** – Flags unencrypted data transmission
- **Audit Linux VMs Without Log Analytics Agent** – Ensures monitoring is enabled

### 📋 Compliance & Reporting

- Policies are assigned at the resource group level.
- Integrated with Defender for Cloud to reflect compliance in the Secure Score.

> 📸 **Recommended Screenshot**: Azure Policy → Compliance dashboard with assigned policy list.

---

## 7. `defender`

**Purpose**: Enables Microsoft Defender for Cloud.

**Components**:
- Auto-provisioning of agents (e.g., Defender for Servers, AKS)
- Policy assignments for CSPM

**Security Features**:
- Enforces secure configuration baselines
- Connects alerts to Sentinel

### 🔄 Auto-Provisioning

- Automatically enables Defender agents across key Azure services:
  - Defender for Servers
  - Defender for App Services
  - Defender for Key Vault
  - Defender for AKS
- Ensures that newly deployed resources are immediately protected without manual setup.

### 🏛️ Cloud Security Posture Management (CSPM)

- Scans the environment continuously to identify risks and misconfigurations.
- Provides **Secure Score** and actionable recommendations.
- Alerts are connected to **Microsoft Sentinel** for centralized visibility.

> 📸 **Recommended Screenshot**: Defender for Cloud dashboard showing Secure Score and recommendations.

---

## 8. `logicapp`

**Purpose**: Automates response to security incidents.

**Components**:
- Logic App with HTTP trigger
- Office 365 email integration

**Security Features**:
- Sends alert emails to SOC team
- Can be extended for auto-remediation (e.g., lock account, disable user)

### 🧪 Triggered by Sentinel Alerts

- Example scenario:
  - Sentinel detects Key Vault deletion
  - Triggers HTTP POST to Logic App
  - Logic App sends alert email to SOC team

### 🔁 Workflow Summary

- Trigger: HTTP request
- Action: Send email via Office 365 Outlook connector

> 📸 **Recommended Screenshot**:
  - Logic App run history showing the alert triggered and email sent
  - Postman request sent to Logic App (simulate alert)

---

## 🔐 Security Architecture Highlights

| Feature                        | Description                                                         |
|-------------------------------|---------------------------------------------------------------------|
| **Zero Trust Network**        | NSGs, Private Endpoints, Azure Firewall, UDR                        |
| **Threat Detection**          | Sentinel analytics + Defender alerts                                |
| **Remediation Automation**    | Logic Apps triggered via Sentinel alert                             |
| **Security as Code**          | Azure Policies deployed via Terraform module                        |
| **IAM Hardening**             | Workload Identity, Key Vault RBAC, conditional access (planned)     |

---

## ✅ Security Outcomes

- Hardened infrastructure using policy enforcement
- Continuous security monitoring with Defender + Sentinel
- Automated alerting and response via Logic App
- Enforced Zero Trust across identity, network, and data layers

---


---

## 9. `policy` – Azure Policy Enforcement (Policy-as-Code)

### 🧩 Purpose

Implements **Azure Policy-as-Code** to automate the enforcement of security and compliance rules across Azure resources. This module ensures that all deployments adhere to predefined organizational standards without requiring manual oversight.

---

### 🔧 Policies Implemented

- **Deny RDP from Internet**:
  - Blocks creation of NSG rules allowing inbound port 3389 (RDP)
- **Deny SSH from Internet**:
  - Prevents inbound access to port 22 from public IPs
- **Deny Public IP Creation**:
  - Restricts assignment of public IPs to compute resources
- **Audit Storage Accounts Without HTTPS**:
  - Flags storage accounts not enforcing secure (HTTPS) traffic
- **Audit Linux VMs Without Log Analytics Agent**:
  - Identifies VMs missing telemetry agents for monitoring

---

### 🔐 Security Features

- **Enforces Zero Trust**:
  - Restricts public entry points (SSH/RDP) at deployment time
- **Misconfiguration Prevention**:
  - Stops insecure resource deployments (e.g., public IPs)
- **Audit-Only Policies**:
  - Detect misaligned configurations without blocking
- **Terraform-Managed Assignments**:
  - Policy definitions and assignments codified as reusable infrastructure

---

### 📸 Recommended Screenshots

| Screenshot                                  | Description                                                   |
|---------------------------------------------|---------------------------------------------------------------|
| **Policy Compliance Overview**              | Overall compliance score from Azure Policy blade             |
| **Assigned Policies View**                  | Shows policies bound to the resource group/subscription      |
| **Non-Compliant Resources List**            | Details on which resources are violating each policy         |
| **Terraform Code Snippet for Assignment**   | Example of policy assignment via Terraform                   |

---

### ✅ Key Benefits

- Establishes automated **security governance** at scale
- Prevents **risky cloud misconfigurations**
- Integrates with **Microsoft Defender for Cloud** to boost Secure Score
- Ensures **consistent enforcement** across all environments

---

## 10. `simulations`

**Purpose**: Simulates real-world attack scenarios to test Sentinel alerts.

**Scenarios Included**:
- Simulated Key Vault deletion
- Simulated suspicious login activity

**Security Features**:
- Generates alerts to validate detection pipelines
- Triggers Logic App via Sentinel

---

📁 Each module is reusable and parameterized for easy deployment across `dev` and `prod` environments. You can find them under the `modules/` directory.

---

# 🚀 CI/CD Pipeline – Azure DevOps Implementation

This document outlines the Azure DevOps CI/CD pipeline configured for secure, automated deployment of the 3-Tier Azure Architecture using Terraform. It includes security scanning, environment segregation, and integration testing.

---

## 📂 File Location

```bash
azure-pipelines.yml  # Root of the repository

``` 

This project uses an automated CI/CD pipeline configured in **Azure DevOps** to provision secure infrastructure using Terraform. The pipeline ensures both **deployment efficiency** and **security validation** through multiple stages.

- **Trigger**: The pipeline is triggered automatically on every push to the `main` branch, ensuring continuous integration and consistent deployments.

- **Security Scan**: 
  - Integrated **`tfsec`** scan acts as a **security gate**, checking Terraform code for misconfigurations before applying changes.
  - If critical issues are found, the pipeline will fail and block deployment, enforcing secure-by-default principles.

- **Pipeline Stages**:
  1. **Terraform Plan & Apply (Dev and Prod)**:
     - Initializes the Terraform backend
     - Plans infrastructure changes
     - Applies modular code across environments (`dev`, `prod`)
     - Manages state in secure Azure Storage

  2. **Azure CLI Login**:
     - Authenticates with Azure using a DevOps service connection
     - Grants permissions to manage resources, query secrets, and simulate access

  3. **Key Vault Access Simulation**:
     - Validates access to Azure Key Vault using Azure CLI
     - Ensures the pipeline identity has correct RBAC permissions

  4. **Sentinel Alert Testing**:
     - Simulates real-world threats (e.g., Key Vault deletion)
     - Validates that Microsoft Sentinel detects and raises incidents
     - Triggers a **Logic App** for automated email alerting or remediation

This pipeline provides a secure, repeatable, and auditable mechanism for deploying and monitoring cloud infrastructure, aligning with DevSecOps best practices.

# 🔐 Security Tools & Features – Detailed Documentation

This document describes all the security tools and services integrated into the 3-Tier Secure Azure Architecture project. These services help enforce best practices, prevent misconfigurations, detect threats, and automate responses.

---
