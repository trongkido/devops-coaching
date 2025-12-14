# Google Cloud Artifact Registry – Overview & Usage Guide

## 1. What is Google Cloud Artifact Registry?

**Google Cloud Artifact Registry** is a fully managed service for storing, managing, and securing build artifacts such as:

- 🐳 Docker / OCI container images
- ☕ Maven packages
- 📦 npm packages
- 🐍 Python (PyPI) packages
- 📁 Generic artifacts

It is the **successor to Container Registry (gcr.io)** and is tightly integrated with:
- GKE
- Cloud Build
- Cloud Run
- IAM & VPC security controls

---

## 2. Key Benefits

- Regional and multi‑regional repositories
- Fine‑grained IAM access control
- Native vulnerability scanning
- Cleanup policies to control storage cost
- Seamless integration with GKE & CI/CD

---

## 3. Pricing Summary (High Level)

| Cost Type | Description |
|---------|-------------|
| Storage | $0.10 per GB‑month (first 0.5 GB free) |
| Upload (Ingress) | Free |
| Download within same region | Free |
| Cross‑region / Internet egress | Standard GCP network pricing |

> 💡 Best practice: create the repository in the **same region as your GKE cluster** to avoid egress costs.

---

## 4. Enable Artifact Registry API

Before using Artifact Registry, enable the API:

```bash
gcloud services enable artifactregistry.googleapis.com
```

---

## 5. Create an Artifact Registry Repository (gcloud)

### 5.1 Example: Create a Docker (OCI) repository

```bash
gcloud artifacts repositories create devops-docker-repo \
  --project=pelagic-pod-476510-v7 \
  --repository-format=docker \
  --location=us-central1 \
  --description="Docker images for DevOps and GKE"
```

### Repository format options

| Format | Value |
|------|------|
| Docker / OCI | docker |
| Maven | maven |
| npm | npm |
| Python (PyPI) | python |
| Generic | generic |

---

## 6. Verify Repository

```bash
gcloud artifacts repositories list \
  --location=us-central1 \
  --project=pelagic-pod-476510-v7
```

---

## 7. Configure Docker Authentication

Authenticate Docker to Artifact Registry:

```bash
gcloud auth configure-docker us-central1-docker.pkg.dev
```

This updates `~/.docker/config.json` automatically.

---

## 8. Push a Docker Image to Artifact Registry

### 8.1 Tag image

```bash
docker tag nginx:latest \
  us-central1-docker.pkg.dev/pelagic-pod-476510-v7/devops-docker-repo/nginx:latest
```

### 8.2 Push image

```bash
docker push \
  us-central1-docker.pkg.dev/pelagic-pod-476510-v7/devops-docker-repo/nginx:latest
```

---

## 9. Pull Image from GKE or Local Machine

```bash
docker pull \
  us-central1-docker.pkg.dev/pelagic-pod-476510-v7/devops-docker-repo/nginx:latest
```

In GKE, ensure:
- Nodes or workloads have permission `roles/artifactregistry.reader`
- Workload Identity is correctly configured (recommended)

---

## 10. IAM Permissions (Common Roles)

| Role | Purpose |
|----|--------|
| Artifact Registry Reader | Pull images |
| Artifact Registry Writer | Push images |
| Artifact Registry Admin | Full control |

Example:

```bash
gcloud projects add-iam-policy-binding pelagic-pod-476510-v7 \
  --member="serviceAccount:my-sa@pelagic-pod-476510-v7.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.reader"
```

---

## 11. Best Practices

- Use **regional repositories** aligned with GKE region
- Enable **cleanup policies** to remove old images
- Prefer **Workload Identity** over service account keys
- Disable public internet pulls in production clusters

---

## 12. Artifact Registry vs Container Registry

| Feature | Artifact Registry | Container Registry |
|------|------------------|------------------|
| Status | Actively developed | Legacy |
| Formats | Multi‑format | Docker only |
| IAM | Fine‑grained | Limited |
| Security | Stronger | Basic |

---

## 13. Useful Commands (Quick Reference)

```bash
# List images
gcloud artifacts docker images list \
  us-central1-docker.pkg.dev/pelagic-pod-476510-v7/devops-docker-repo

# Delete image
gcloud artifacts docker images delete IMAGE_URL

# Describe repository
gcloud artifacts repositories describe devops-docker-repo \
  --location=us-central1
```

---

## 14. Summary

Google Cloud Artifact Registry is the recommended solution for storing container images and build artifacts on GCP. It provides strong security, seamless GKE integration, and predictable pricing when used with proper regional design.

