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
- https://github.com/trongkido/devops-coaching/blob/main/gcp/create-gke-cluster/ingress-nginx-on-gke/README.md

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

Now, we will prepare a CI pipeline with groovy script (Jenkinsfile) to build image, update values.yaml file and push to repository.
```groovy
pipeline {
  agent none

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  environment {
    // Variables for docker build and k8s deployment
    APP_NAME = "easy-rbac"
    APP_HOST = "easy-rbac.trongnv.xyz"
    DOCKER_REGISTRY = "https://registry-nexus.trongnv.xyz"
    REGISTRY_HOST = DOCKER_REGISTRY.replace("https://", "").replace("http://", "")
    DOCKER_CREDENTIALS = credentials('docker-login')
    APP_IMAGE_NAME = "${env.REGISTRY_HOST}/${env.APP_NAME}/${env.APP_NAME}"
    APP_IMAGE_TAG = "${BUILD_NUMBER}"
    PULL_SECRET = "nexus-registry-secret"
    K8S_NAMESPACE = "app-dev"
    HARBOR_URL = "https://harbor-registry.trongnv.xyz"
    HARBOR_HOST = HARBOR_URL.replace("https://", "").replace("http://", "")
    HARBOR_PROJECT = "devops-coaching"
    HELM_CHART = "app-template"
    HARBOR_CREDENTIALS = credentials('helm-login')
    LOCAL_GITLAB_URL = "https://mygitlab.trongnv.xyz"
    LOCAL_GITLAB_PROJECT_ID = "3"
    LOCAL_GITLAB_BRANCH = "main"
    LOCAL_GITLAB_TOKEN = credentials('pipeline-token')
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
        sh "docker build -t ${APP_IMAGE_NAME}:${APP_IMAGE_TAG} ."
        echo "INFO: Building App image: ${env.APP_IMAGE_NAME} successfylly"

        // Push to local registry
        echo "INFO: Pushing App image to local registry ${env.DOCKER_REGISTRY}..."
        sh '''
              echo $DOCKER_CREDENTIALS_PSW | docker login ${DOCKER_REGISTRY} -u $DOCKER_CREDENTIALS_USR --password-stdin
              docker push ${APP_IMAGE_NAME}:${APP_IMAGE_TAG}
              docker logout ${DOCKER_REGISTRY}
           '''
        echo "INFO: Pushing App image to local registry ${env.DOCKER_REGISTRY} successfully"
      }
    }

    // --- Stage 3: Update helm template and push to harbor ---
    stage('3. Update helm template and push to harbor') {
      agent {
        label 'docker-lab'
      }
      steps {
        echo "INFO: Updating helm template..."
        sh '''
              echo $HARBOR_CREDENTIALS_PSW | helm registry login ${HARBOR_HOST}:8088 -u $HARBOR_CREDENTIALS_USR --password-stdin
              helm pull oci://${HARBOR_HOST}:8088/${HARBOR_PROJECT}/${HELM_CHART} --destination /tmp/
              if [ ! -f /usr/bin/yq ]; then
                 curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/bin/yq
                 chmod +x /usr/bin/yq
              fi
              if [ ! -f /usr/bin/jq ]; then
                 curl -L https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 /usr/bin/jq
                 chmod +x /usr/bin/jq
              fi
	      helm_version=$(curl -s -u $HARBOR_CREDENTIALS_USR:$HARBOR_CREDENTIALS_PSW "${HARBOR_URL}/api/v2.0/projects/${HARBOR_PROJECT}/repositories/${HELM_CHART}/artifacts" | jq -r '.[].tags[].name')
	      cd /tmp/ && tar -xf ${HELM_CHART}-${helm_version}.tgz
              rm /tmp/${HELM_CHART}-${helm_version}.tgz -f
              cd /tmp/${HELM_CHART}
              yq e -i '
                .imagePullSecrets = [{"name": strenv(PULL_SECRET)}] |
  		.image.repository = strenv(APP_IMAGE_NAME) |
  		.image.tag = strenv(APP_IMAGE_TAG) |
  		.ingress.hosts[0].host = strenv(APP_HOST)
	      ' values.yaml
              cd /tmp/
              helm package ${HELM_CHART}
              helm push ${HELM_CHART}-${helm_version}.tgz oci://${HARBOR_HOST}:8088/${HARBOR_PROJECT}
              cd /tmp/ && rm ${HELM_CHART}-${helm_version}.tgz ${HELM_CHART} -rf
              helm registry logout ${HARBOR_HOST}:8088
          '''
          echo "INFO: Updated helm template successfully"
      }
    }

    // --- Stage 4: Deploy app to on-prem k8s cluster with local argocd ---
    stage('4. Deploy app to on-prem k8s cluster with local argocd') {
      agent {
        label 'docker-lab'
      }
      steps {
          sh '''
                echo "Push trigger to gitlab CD pipeline!!!"
                curl -X POST \
                  --form token=$LOCAL_GITLAB_TOKEN \
                  --form ref=$LOCAL_GITLAB_BRANCH \
                  --form variables[LOCAL_APP_NAME]="${APP_NAME}" \
                  --form variables[LOCAL_PROJECT]="dev-homelab" \
                  --form variables[LOCAL_HELM_REPO]="$HARBOR_HOST:8088/$HARBOR_PROJECT" \
                  --form variables[HELM_CHART]="$HELM_CHART" \
                  --form variables[HELM_VERSION]="0.1.1" \
                  --form variables[LOCAL_K8S_CLUSTER]="https://kubernetes.default.svc" \
                  --form variables[APP_NAMESPACE]="K8S_NAMESPACE" \
                  --form variables[VALUE_FILE]="values.yaml" \
                  $LOCAL_GITLAB_URL/api/v4/projects/$LOCAL_GITLAB_PROJECT_ID/trigger/pipeline
             '''
      }
    }
  }
}
```

Before running this CI pipeline, you must create these essential requirements
You need to generate a gitlab trigger pipeline token
![Alt text](./images/final-lab-gen-trigger-token.png)

Then add the token to Jenkins
![Alt text](./images/final-lab-jenkins-add-token.png)

After that, add variables on gitlab
![Alt text](./images/final-lab-gitlab-add-variables.png)

Create a pull images secret for dev namespace and backup prod namespace on local
```text
kubectl get secret -n app-dev
NAME                    TYPE                             DATA   AGE
nexus-registry-secret   kubernetes.io/dockerconfigjson   1      23d

kubectl get secret -n prod-dr
NAME                    TYPE                             DATA   AGE
nexus-registry-secret   kubernetes.io/dockerconfigjson   1      33s
```

You need to install ArgoCD CLI, please check guide here: https://github.com/trongkido/devops-coaching/tree/main/aws/create-eks-cluster/running-argocd-on-eks-cluster

Then, you need to create a account token, before, you need to create an ArgoCD account for this project and grant least privilege for this account, please follow this guide: https://github.com/trongkido/devops-coaching/blob/main/argocd/argocd-rbac/README.md

After that, you need to create gitlab runner, please refer here: https://github.com/trongkido/devops-coaching/blob/main/git-cicd/hands-on-cicd-lab/README.md

Then, create a gitlab CD pipeline
```text
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "trigger"
      when: always
    - when: never

stages:
  - deploy-local
  - local-test
  - cto-approval
  - deploy-cloud

push-to-local-argo:deploy-local:
  stage: deploy-local
  image:
    name: quay.io/argoproj/argocd:v2.11.3
  variables:
    GIT_STRATEGY: none
  before_script:
    - export LOCAL_ARGOCD_CONNECTION_STRING="--auth-token $LOCAL_ARGOCD_TOKEN --server $LOCAL_ARGOCD_SERVER --insecure --grpc-web"
  script:
    - |
        echo "🔐 Logging in to Local Argo CD and searching for application $LOCAL_APP_NAME"
        APP=$(argocd app list $LOCAL_ARGOCD_CONNECTION_STRING | awk '{print $1}' | grep -w "$LOCAL_APP_NAME" || true)
        echo "$APP"
        if [ -z "$APP" ]; then
          echo "No applications found, create new."
          argocd app create $LOCAL_APP_NAME $LOCAL_ARGOCD_CONNECTION_STRING \
            --project $LOCAL_PROJECT \
            --repo $LOCAL_HELM_REPO \
            --helm-chart $HELM_CHART \
            --revision $HELM_VERSION \
            --dest-server $LOCAL_K8S_CLUSTER \
            --dest-namespace $APP_NAMESPACE \
            --values $VALUE_FILE \
            --sync-policy automated \
            --self-heal \
            --sync-option CreateNamespace=true \
            --sync-option PruneLast=true \
            --upsert
        else
           echo "Force sync for the following applications:"
           echo "$APP"
           argocd app sync $LOCAL_ARGOCD_CONNECTION_STRING "$APP"
           echo "Sync finish"
        fi

local-test:
  stage: local-test
  variables:
    GIT_STRATEGY: none
  allow_failure: false
  script:
    - |
        echo "Testing for vulnerability"
        # Your test command here
        echo "Testing for business logic"
        # Your test command here
  needs:
    - job: push-to-argo:deploy-local

approval:confirm-deploy:
  stage: cto-approval
  variables:
    GIT_STRATEGY: none
  script:
    - echo "Waiting for CTO approval before pushing Docker images and deploy to cloud production..."
  when: manual
  only:
    - main
  environment:
    name: cloud-production
    url: https://$CLOUD_ARGOCD_SERVER
  needs:
    - job: local-test

# Push image to cloud registry
push-image-cloud:deploy-cloud:
  stage: deploy-cloud
  variables:
    GIT_STRATEGY: none
  allow_failure: false
  script:
    - |
        echo "Login to $GCLOUD_REGISTRY"
        docker login $GCLOUD_REGISTRY -u _json_key --password-stdin < "$GCLOUD_CREDENTIALS"
        echo "Login to $GCLOUD_REGISTRY successfully!"
        docker tag $LOCAL_APP_REPO/${LOCAL_APP_NAME}:${IMAGE_TAG} $GCLOUD_REGISTRY/$GCLOUD_REPO/$LOCAL_APP_NAME:$IMAGE_TAG
        docker push $GCLOUD_REGISTRY/$GCLOUD_REPO/$LOCAL_APP_NAME:$IMAGE_TAG
        echo "Logout from $GCLOUD_REGISTRY"
        docker logout $GCLOUD_REGISTRY
  needs:
    - job: approval:confirm-deploy

# Update github value file
update-github:deploy-cloud:
  stage: deploy-cloud
  image:
    name: alpine:3.19
  variables:
    GIT_STRATEGY: none
  allow_failure: false
  before_script:
    # Install dependencies
    - apk add --no-cache git curl bash
    # Install yq (mikefarah)
    - curl -s -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq
    - chmod +x /usr/local/bin/yq
    # Configure git
    - git config --global user.email "gitlab-ci@gmail.com"
    - git config --global user.name "Gitlab CI/CD Automation"
    - export GITHUB_BRANCH="main"
  script:
    - |
      echo "Fetch github repo"
      git clone https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/trongkido/${LOCAL_APP_NAME}.git
      echo "Update values.yaml file"
      cd ${LOCAL_APP_NAME}
      cp helm/app-template/values.yaml helm/app-template/values-prod.yaml
      yq e -i '
        .imagePullSecrets = "" |
        .image.repository = strenv(GCLOUD_REGISTRY) + "/" + strenv(GCLOUD_REPO) + "/" + strenv(LOCAL_APP_NAME) |
        .image.tag = strenv(IMAGE_TAG) |
        .ingress.hosts[0].host = strenv(CLOUD_APP_HOST) |
        .ingress.certmanager = {
          "enabled": true,
          "issuename": "letsencrypt-prod",
          "issueacme": "https://acme-v02.api.letsencrypt.org/directory"
        } |
        .ingress.tls = [
          {
            "hosts": [strenv(CLOUD_APP_HOST)],
            "secretName": strenv(CLOUD_APP_TLS)
          }
        ]
      ' helm/app-template/values-prod.yaml
      echo "Update file values-prod.yaml to github repo"
      git add helm/app-template/values-prod.yaml
      git commit -m "chore(cd): update image tag and ingress config"
      git push origin ${GITHUB_BRANCH}
  needs:
    - job: push-image-cloud:deploy-cloud

# Deploy to gke
push-to-cloud-argo:deploy-cloud:
  stage: deploy-cloud
  image:
    name: quay.io/argoproj/argocd:v2.11.3
  variables:
    GIT_STRATEGY: none
  before_script:
    - export CLOUD_ARGOCD_CONNECTION_STRING="--auth-token $CLOUD_ARGOCD_TOKEN --server $CLOUD_ARGOCD_SERVER --insecure --grpc-web"
  script:
    - |
        echo "🔐 Logging in to Cloud ArgoCD and searching for application $APP_NAME"
        APP=$(argocd app list $CLOUD_ARGOCD_CONNECTION_STRING | awk '{print $1}' | grep -w "$APP_NAME" || true)
        echo "$CLOUD_APP"
        if [ -z "$CLOUD_APP" ]; then
          echo "No applications found, create new."
          echo "$APP_NAME"
          argocd app create $APP_NAME $CLOUD_ARGOCD_CONNECTION_STRING \
            --project $CLOUD_PROJECT \
            --repo $GITHUB_REPO \
            --path $HELM_PATH \
            --revision $GITHUB_BRANCH \
            --dest-server $CLOUD_K8S_CLUSTER \
            --dest-namespace $CLOUD_APP_NAMESPACE \
            --values $CLOUD_VALUE_FILE \
            --sync-policy automated \
            --self-heal \
            --sync-option CreateNamespace=true \
            --sync-option PruneLast=true \
            --upsert
        else
           echo "Force sync for the following applications:"
           echo "$CLOUD_APP"
           argocd app sync $CLOUD_ARGOCD_CONNECTION_STRING "$CLOUD_APP"
           echo "Sync finish"
        fi
  needs:
    - job: update-github:deploy-cloud
```

Run pipeline
Jenkins
[Alt text](./images/final-lab-jenkins-pipeline.png)

Gitlab
[Alt text](./images/final-lab-gitlab-pipeline.png)

Update record on CloudFlare
[Alt text](./images/final-lab-cloudflare-update-record.png)

Check access from internet
App on GKE
[Alt text](./images/final-lab-app-access-on-gke.png)

App on local
[Alt text](./images/final-lab-app-access-on-local.png)

### Disaster Recovery Scenario (DR Test)
1. Access main website: `gke-easy-rbac.trongnv.xyz` (running on GKE).
2. Simulate failure: Shut down EKS (or scale nodes to 0).
3. Failover:
   - Update **Cloudflare DNS** to point traffic to **DR Tunnel** (easy-rbac.trongnv.xyz)
4. Result:
   - Website remains available (served from Local On-Premise).
