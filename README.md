# azure-3tier-secure-infra
# 🔐 Azure 3-Tier Secure Architecture – Terraform Automation

This project provisions a secure, production-ready 3-Tier architecture in Azure using **Terraform**, **Microsoft Defender**, and **Sentinel**. It integrates zero trust principles, workload identity, custom role assignments, and automated CI/CD security enforcement.

---

## 📐 Architecture Overview

**Tier 1 – Web Layer:**
- Azure App Gateway (WAF_v2)
- Azure Front Door
- Private DNS + NSGs

**Tier 2 – App/API Layer:**
- AKS Cluster (OIDC + Workload Identity)
- Azure Functions + API Gateway
- Key Vault integration with federation

**Tier 3 – Data Layer:**
- Azure SQL / Storage / Redis
- Private Endpoints + Firewall + NSG

---

## 🛡️ Security Implementations

- Microsoft Defender for AKS, Key Vault, Storage
- Microsoft Sentinel + Alert Rules + Connectors
- Zero Trust: Conditional Access, RBAC, Workload Identity
- tfsec, Checkov CI/CD enforcement in Azure DevOps

---

## 📦 Modules Implemented

- `modules/networking/` – VNet, NSGs, Private DNS
- `modules/waf/` – App Gateway with WAF
- `modules/aks/` – AKS with OIDC & identity
- `modules/iam/` – RBAC, custom roles, access policies
- `modules/sentinel/` – LA Workspace, analytics rules, connectors
- `modules/defender/` – Defender plans per service
- `modules/keyvault/` – Vault + access policy management
- `modules/firewall/` – Azure Firewall + UDR

---

## 🚀 CI/CD Pipeline

- Azure DevOps YAML
- tfsec + Checkov scans
- Manual approval gates for `prod`
- Variable groups for secure secrets
