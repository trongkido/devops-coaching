# Hybrid Cloud Terraform Project (AWS + Proxmox + HCP Terraform)

------------------------------------------------------------------------

## 1. Project Overview

This project demonstrates a **Hybrid Cloud Infrastructure** using:

-   **AWS Public Cloud**
-   **Proxmox On‑Premise Virtualization**
-   **HCP Terraform (Terraform Cloud)**

The architecture separates workloads into:

  Layer              Location
  ------------------ ---------------
  Web Tier           AWS
  Load Balancing     AWS ALB
  Database Tier      Proxmox
  State Management   HCP Terraform

Purpose:

-   Demonstrate **Infrastructure as Code**
-   Implement **Hybrid Cloud architecture**
-   Show **team collaboration workflow**
-   Follow **DevOps & Solution Architect best practices**

------------------------------------------------------------------------

# 2. Architecture Diagram

                    Internet
                        │
                AWS Application Load Balancer
                        │
               Auto Scaling Web Servers (EC2)
                        │
                 Private Networking
                        │
            VPN / Routing (Optional Improvement)
                        │
                On‑Premise Proxmox Cluster
                        │
                  Database Virtual Machine
                 (MySQL / PostgreSQL Server)

```
┌─────────────────────────────────────────────────────────────────┐
│                        HCP Terraform                            │
│              (State Management + Approval Gate)                 │
└──────────────────┬──────────────────────┬───────────────────────┘
                   │                      │
       ┌───────────▼──────────┐  ┌────────▼────────────────┐
       │     AWS (Public)     │  │  Proxmox (On-Premise)   │
       │                      │  │                         │
       │  ┌────────────────┐  │  │  ┌──────────────────┐   │
       │  │      ALB       │  │  │  │   VM: Database   │   │
       │  └───────┬────────┘  │  │  │ (MySQL/Postgres) │   │
       │          │           │  │  └──────────────────┘   │
       │  ┌───────▼────────┐  │  │   Static IP: 10.x.x.x   │
       │  │ EC2 Web Servers│  │  │                         │
       │  │ (Auto Scaling) │  │  └─────────────────────────┘
       │  └────────────────┘  │           ▲
       │   VPC + Subnets      │           │
       │   Security Groups    │   VPN / Site-to-Site
       └──────────────────────┘    (Routing Layer)
```

- **Internet → ALB → EC2 Web Servers** (Public traffic)
- **EC2 Web Servers → Proxmox DB** (Private traffic qua VPN/Routing)
- **Terraform CLI (Local)** → HCP Terraform API → AWS API + Proxmox API

Outputs:

-   AWS ALB DNS
-   Proxmox Database VM IP


------------------------------------------------------------------------

# 3. Required Tools

Install:

    Terraform >= 1.6
    AWS CLI
    Git
    kubectl (optional future extension)
    Proxmox API Token

Accounts required:

-   AWS Account
-   HCP Terraform account
-   Proxmox server

------------------------------------------------------------------------

## 4. Recommended Repository Structure

    terraform-hybrid-architecture
    │
    ├── main.tf
    ├── providers.tf
    ├── variables.tf
    ├── outputs.tf
    │
    ├── modules
    │   ├── aws-network
    │   ├── aws-compute
    │   ├── aws-alb
    │   └── proxmox-db
    │
    ├── scripts
    │   └── install_database.sh
    │
    └── diagrams
        └── architecture.png

This design follows **clean modular architecture**.

------------------------------------------------------------------------

## 5. Setup HCP Terraform

Terraform supports remote backend with Terraform Cloud (HCP Terraform). They provide four main pricing tiers: Free (up to 500 managed resources), Standard, Plus, and Premium, designed for different team sizes and needs.
To leverage Terraform Cloud as a remote backend, first we need to create a terraform cloud account. For the full guide to create a HPC Terraform account, please follow this guide 
```link
https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up
```

After create a new account, Login to with your new account
```link
https://app.terraform.io
```

### 5.1 Create Organization

In Terraform, an organization is a top-level entity within HCP Terraform (formerly Terraform Cloud) and Terraform Enterprise used to provide a shared environment for teams to collaborate on infrastructure as code, manage resources, and enforce governance

1. After login to HPC, choose **Manage Organizations** → **Create new organization**
![Alt text](./images/tf-create-org1.png)

2. Choose **Personal** (because I use my own account) → Fill your organization name → **Create Organization**
![Alt text](./images/tf-create-org2.png)

3. Invite member to Organization with **Organizations** → **Settings** → **Users** → **Invite a user**
![Alt text](./images/tf-add-users.png)

4. Add team member with **Organizations** → **Settings** → **Teams** → **Add members**
![Alt text](./images/tf-add-members.png)

### 5.2 Create Project and Workspace
In HCP Terraform, Projects are organizational containers used to group related infrastructure, manage team permissions, and set policies. Workspaces are the fundamental, isolated units within projects that store state files, variables, and run history for specific infrastructure components. Projects help scale management, while workspaces handle the deployment lifecycle.

1. **Organizations** → **Project** → **New Project**
![Alt text](./images/tf-create-project.png)

2. **Organizations** → **Project** → **Workspaces** → **New** → **Workspace** → **Version Control Workflow** → **Github** → **Login with Github email and password** → **Authorize Terraform Cloud**

2. **Organizations** → **Project** → **Workspaces** → **New** → **Workspace** → **Version Control Workflow** → **Github (Custom)** → **register a new OAuth Application** 
![Alt text](./images/tf-create-workspace1.png)

On Github, choose **Register application** → **Generate a new client secret*


3. ⚠️ **NOTE – Change Execution Mode:**
   - Go to **Workspace** → **Settings** → **General**
   - Change **Execution Mode** from `Remote` to **`Local`**
   - Reason: Proxmox run in local network, Terraform CLI must be run on local
![Alt text](./images/tf-change-execution-mode.png)

### 5.3 Config Sensitive Variables

On **Workspaces** → **Variables** → **Add variable**



