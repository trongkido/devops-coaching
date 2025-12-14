# Google Cloud Platform (GCP) – Overview & Account Creation Guide

## 1. What is Google Cloud Platform (GCP)?

**Google Cloud Platform (GCP)** is a suite of cloud computing services offered by Google. It provides infrastructure, platform, and software services that run on the same global infrastructure used by Google products like Search, Gmail, and YouTube.

GCP is commonly used for:
- Cloud-native applications
- Kubernetes workloads (GKE)
- DevOps & CI/CD
- Big Data & Analytics
- AI / Machine Learning
- Hybrid & multi-cloud architectures

---

## 2. Core GCP Service Categories

### 2.1 Compute
- **Compute Engine** – Virtual Machines (IaaS)
- **Google Kubernetes Engine (GKE)** – Managed Kubernetes
- **Cloud Run** – Serverless containers
- **App Engine** – PaaS for web applications

### 2.2 Storage & Databases
- **Cloud Storage** – Object storage
- **Persistent Disk** – VM block storage
- **Filestore** – Managed NFS
- **Cloud SQL** – Managed relational databases
- **Spanner** – Globally distributed SQL
- **Firestore / Bigtable** – NoSQL databases

### 2.3 Networking
- **VPC** – Virtual Private Cloud
- **Cloud Load Balancing** – Global L4/L7 LB
- **Cloud DNS** – Managed DNS
- **Cloud NAT** – Outbound internet access
- **Interconnect / VPN** – Hybrid connectivity

### 2.4 DevOps & Containers
- **Artifact Registry** – Container & package registry
- **Cloud Build** – CI/CD
- **Cloud Deploy** – Release management
- **Operations Suite** – Logging & Monitoring

### 2.5 Security & IAM
- **IAM** – Identity & Access Management
- **Service Accounts** – Machine identities
- **Secret Manager** – Secret storage
- **Binary Authorization** – Image security
- **Security Command Center** – Security posture

---

## 3. GCP Global Infrastructure

- Regions → Zones architecture
- High-performance private global network
- Built-in redundancy and availability

Example:
- Region: `us-central1`
- Zones: `us-central1-a`, `us-central1-b`, `us-central1-c`

---

## 4. GCP Pricing Model (High Level)

GCP uses a **pay-as-you-go** model:

- No upfront cost
- Per-second or per-minute billing (service dependent)
- Sustained use discounts (automatic)
- Committed use discounts (optional)

Common free tiers:
- $300 free trial credit (new accounts)
- Always-free usage for select services

---

## 5. How to Create a Google Cloud (GCP) Account

### 5.1 Prerequisites

You need:
- A Google account (Gmail or Google Workspace)
- A valid credit/debit card (for verification)

> 💡 Google will not charge you automatically during the free trial unless you upgrade.

---

### 5.2 Step-by-Step: Create GCP Account

1. Open the Google Cloud website:
   
   https://cloud.google.com

2. Click **“Get started for free”**

3. Sign in with your Google account

4. Choose:
   - Country
   - Agree to terms

5. Set up billing:
   - Enter payment information
   - Identity verification

6. Receive **$300 free credit** (valid for 90 days)

7. Your first **GCP project** is created automatically

---

## 6. GCP Project Basics

Everything in GCP lives inside a **Project**.

A project includes:
- Project ID (unique)
- Billing account
- APIs & services
- IAM policies

You can create more projects later.

---

## 7. Access GCP Using CLI (gcloud)

### 7.1 Install Google Cloud CLI

- macOS (Homebrew):
```bash
brew install --cask google-cloud-sdk
```

- Linux (RHEL / Rocky / Ubuntu supported)
- Windows installer available

---

### 7.2 Initialize gcloud

```bash
gcloud init
```

This will:
- Authenticate your Google account
- Select a project
- Configure default region/zone

Verify:
```bash
gcloud config list
```

---

## 8. Create a New Project (Optional)

```bash
gcloud projects create my-first-gcp-project
```

Link billing:
```bash
gcloud billing projects link my-first-gcp-project \
  --billing-account=XXXXXX-XXXXXX-XXXXXX
```

---

## 9. Common GCP Concepts (Beginner Friendly)

| Concept | Description |
|------|------------|
| Project | Logical container for resources |
| Region | Physical location |
| Zone | Data center within region |
| IAM | Access control |
| Service Account | Identity for workloads |
| API | Service interface |

---

## 10. Best Practices for New GCP Users

- Use **projects** to separate environments (dev / prod)
- Grant **least-privilege IAM** roles
- Enable only required APIs
- Monitor billing and set budgets
- Prefer managed services (GKE, Cloud SQL)

---

## 11. Who Should Use GCP?

- Startups and enterprises
- Kubernetes-first teams
- Data & AI workloads
- Hybrid / multi-cloud strategies

---

## 12. Summary

Google Cloud Platform provides a powerful, secure, and scalable cloud ecosystem. Creating a GCP account is simple, and the free tier allows you to explore most services with no immediate cost.

This document gives you a solid foundation to start using GCP confidently.
