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
- Create **AWS ECR / GCLOUD GAR** (Container Registry).
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
- https://github.com/trongkido/devops-coaching/blob/main/aws/aws-ecr/README.md
- https://github.com/trongkido/devops-coaching/blob/main/aws/deploy-helm/README.md

In this module, I will using Google Cloud GKE and Google Cloud Artifact Registry
**Create a Google Cloud GKE Cluster**
Please follow this guide
- https://github.com/trongkido/devops-coaching/blob/main/gcp/create-gke-cluster/README.md

**Create Google Artifact Registry**
Please follow this guide
- https://github.com/trongkido/devops-coaching/blob/main/gcp/gcp-artifact-registry/README.md

**Setup ArgoCD on GKE Cluster**
Please follow this guide
- https://github.com/trongkido/devops-coaching/blob/main/gcp/create-gke-cluster/running-argocd-on-gke/README.md 

**Setup Ingress Nginx on GKE Cluster**
Follow this guide
- 

**Setup Github Repository**
Please follow this guide
- https://www.geeksforgeeks.org/git/creating-repository-in-github/

### Working On This LAB
For lab project, I will use my small project
https://github.com/trongkido/easy-rbac

Because the **Special requirement**: Source code must remain **internal**. Only **release-ready versions** are pushed to the Public Cloud. So I will push my code to my local Gitlab server.
**Components on Local**
Gitlab
> My code is push here
- https://mygitlab.trongnv.xyz/projectmng/easy-rbac
[Alt text](./images/final-lab-gitlab.png)

Jenkins
https://jenkins.trongnv.xyz
[Alt text](./images/final-lab-jenkins.png) 

Nexus
- https://nexus.trongnv.xyz/
[Alt text](./images/final-lab-nexus.png)

Harbor
- https://harbor-registry.trongnv.xyz/harbor/projects
[Alt text](./images/final-lab-harbor.png)

Local k8s cluster with ArgoCD
- https://argocd.trongnv.xyz/
[Alt text](./images/final-lab-argocd.png)

**Components on Cloud**
Google Artifact Registry
[Alt text](./images/final-lab-gar.png)

GKE Cluster with ArgoCD
[Alt text](./images/final-lab-gke-argocd.png)

Now, we will need to create a new pipeline project in Jenkins with configuration connect to local Gitlab project
[Alt text](./images/final-lab-jenkins-to-gitlab.png)

> [!NOTE]
> In order to connect to Gitlab, Nexus (Local Docker Repo) from Jenkins, we need to add credentials on Jenkins
[Alt text](./images/final-lab-jenkins-credentials.png)

Next, we need to create a webhook from Gitlab to Jenkins to trigger pipeline. The pipeline will run only with merge request events and tag push events
[Alt text](./images/final-lab-gitlab-webhook.png)

Then, we need to add harbor helm repository on local ArgoCD
[Alt text](./images/final-lab-local-argocd-add-repo.png)

After that, we will connect GKE ArgoCD with github project that manage the helm template
[Alt text](./images/final-lab-gke-argocd-add-repo.png)

Now, we will prepare a pipeline with groovy script (Jenkinsfile)
```groovy
pipeline {
  agent none 

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  environment {
    // Variables for docker build and k8s deployment
    APP_NAME = "easy-rbac"
    #APP_SERVICE_NAME = "${env.APP_NAME}-svc"
    #APP_INGRESS_NAME = "${env.APP_NAME}-ingress"
    #APP_HOST_URL = "http://easy-rbac.trongnv.xyz" 
    DOCKER_REGISTRY = "https://registry-nexus.trongnv.xyz"
    REGISTRY_HOST = DOCKER_REGISTRY.replace("https://", "").replace("http://", "")
    DOCKER_CREDENTIALS = credentials('docker-login')
    APP_IMAGE_NAME = "${env.REGISTRY_HOST}/${env.APP_NAME}/${env.APP_NAME}"
    APP_IMAGE_TAG = "${BUILD_NUMBER}"
    K8S_NAMESPACE = 'app-dev'
  }

  stages {
    
    // --- Stage 1: Get latest code ---
    stage('1. Checkout Code') {
      agent {
        label 'docker-lab'
      }
      steps {
        echo 'Starting to check out code from Gitlab...'
        checkout scm 
        echo "SUCCESS: Code checked out from Gitlab."
      }
    }

    // --- Stage 2: Build Docker Images and Push App to Registry ---
    stage('2. Build Docker Images and Push App to Local Docker Registry') {
      agent {
        label 'docker-lab'
      }
      steps {
        // Build
        echo "INFO: Building App image: ${env.APP_IMAGE_NAME}"
        sh "docker build -t ${env.APP_IMAGE_NAME}:${env.APP_IMAGE_TAG} ."
        echo "INFO: Building App image: ${env.APP_IMAGE_NAME} successfylly"

        // Push to local registry
        echo "INFO: Pushing App image to local registry ${env.DOCKER_REGISTRY}..."
        sh '''
              echo $DOCKER_CREDENTIALS_PSW | docker login ${DOCKER_REGISTRY} -u $DOCKER_CREDENTIALS_USR --password-stdin
              docker push ${env.APP_IMAGE_NAME}:${env.APP_IMAGE_TAG}
              docker logout ${env.DOCKER_REGISTRY}
           '''
        echo "INFO: Pushing App image to local registry ${env.DOCKER_REGISTRY} successfully" 
      }

      // --- Stage 3: Update manifest ---
      
    }
  }
}
```



