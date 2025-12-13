# BUILDING A HYBRID CLOUD DR & GITOPS SYSTEM

**Hands-on Lab: Combining AWS EKS, On-Premise Kubernetes, and GitOps Flow**

---

## PROJECT OVERVIEW

### Background
The company **“LAB Finance Global”** requires a CI/CD application deployment system that ensures **High Availability (HA)** and **Disaster Recovery (DR)**.

### Key Challenges
- The **Primary system** runs on the Cloud (AWS EKS) to serve global customers with high performance.
- The **Disaster Recovery (DR) site** runs **On-Premise** to handle cloud outages (region failures, submarine cable issues).
- **Special requirement**: Source code must remain **internal**. Only **release-ready versions** are pushed to the Public Cloud.

---

## TECHNICAL REQUIREMENTS

### Infrastructure Setup

#### 🏢 On-Premise (DR Site)
- Build a local Kubernetes cluster.
- Deploy core tools: **Jenkins, GitLab, Harbor**.
- Configure **Cloudflare Tunnel** to:
  - Public DR App: `dr.tonytechlab.com` → Local NGINX Ingress.
  - (Optional) Connect Cloud ArgoCD to Local GitLab.

#### ☁️ Cloud (Primary Site)
- Deploy **AWS EKS / GCLOUD GKE** (Production).
- Create **AWS ECR / GCLOUD GAR ** (Container Registry).
- Create **GitHub Repository (Public/Private)** for Production configuration.

### CI/CD Pipeline Workflow
![Alt text](./images/Lab-CI-CD-Final-scaled.png)

---

## ENVIRONMENT SETUP
### On DR Site (On-Premise)
You can follow these instruction to setup environment in Local
- K8s Cluster: https://medium.com/@brunosquassoni/creating-a-kubernetes-cluster-step-by-step-bd9ae3c85275 or https://devopscube.com/setup-kubernetes-cluster-kubeadm/
- Jenkins: https://github.com/trongkido/devops-coaching/blob/main/jenkins/hand-on-jenkins-cicd/README.md
- Gitlab: https://github.com/trongkido/devops-coaching/blob/main/git-cicd/hands-on-cicd-lab/README.md
- Harbor: https://github.com/trongkido/devops-coaching/blob/main/argocd/hands-on-lab-with-argocd/argocd-with-helm/README.md

### On Cloud
For Cloud environment
If you want to use AWS, please follow these intructions
- https://github.com/trongkido/devops-coaching/tree/main/aws
- https://github.com/trongkido/devops-coaching/tree/main/aws/create-eks-cluster
- 

In this module, I will using Google Cloud GKE and Google Cloud Artifact Registry
#### Create a Google Cloud GKE Cluster
 
 
