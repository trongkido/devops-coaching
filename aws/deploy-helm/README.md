# Deploying Helm Chart via ArgoCD with Nginx Load Balancer on EKS

## 🏗️ PART 1: INSTALLING NGINX WITH AWS ACM (NLB SSL TERMINATION)

This is the most important change. We configure AWS NLB to automatically attach an ACM SSL certificate to port 443.

>[!NOTE]
>Preparation
>Copy the ARN of your ACM certificate for `*.yourdomain.com`. 
>Example:
```text
arn:aws:acm:ap-southeast-1:241688915712:certificate/70c58476-9a59-4bdc-b1df-cca71c88963a
```

### Install Ingress Nginx
Replace the ARN with your own:
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm repo list 

helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service.beta.kubernetes.io/aws-load-balancer-type"="nlb" \
  --set controller.service.annotations."service.beta.kubernetes.io/aws-load-balancer-scheme"="internet-facing" \
  --set controller.service.annotations."service.beta.kubernetes.io/aws-load-balancer-ssl-cert"="arn:aws:acm:your-cert-here" \
  --set controller.service.annotations."service.beta.kubernetes.io/aws-load-balancer-ssl-ports"="443" \
  --set controller.service.targetPorts.https=http
```

**Why These Parameters?**
- `aws-load-balancer-ssl-cert` → Attaches ACM certificate to NLB  
- `aws-load-balancer-ssl-ports` → Enables port 443  
- `targetPorts.https=http` → SSL offloading at NLB, forward HTTP (80) to Nginx

## 🛡️ PART 2: OPEN NODE PORT RANGE (REQUIRED)

EKS automatically creates a default Security Group for Worker Nodes.  
You must open NodePort ranges for NLB to send traffic.

### Step 1: Identify Worker Node Security Group
1. AWS Console → EC2 → Instances  
2. Select a Worker Node  
3. Open **Security** tab  
4. Look for SG named:
```
eks-cluster-sg-<cluster-name>-xxxx
```

### Step 2: Add Inbound Rule
Add rule:

| Field | Value |
|-------|-------|
| Type | Custom TCP |
| Port range | 30000–32767 |
| Source | 0.0.0.0/0 |
| Description | Allow Nginx Ingress Traffic |

![Alt text](./images/aws-add-inbound-nlb.png)

## 🚀 PART 3: DEPLOY APPLICATION WITH ARGOCD

Since NLB handles SSL, your app Ingress **no longer needs a `tls:` section**.

You can refer to this link https://github.com/trongkido/devops-coaching/tree/main/argocd/hands-on-lab-with-argocd/argocd-with-helm about arogcd working with helm

### Steps:
1. Add your Git repo in ArgoCD 
![Alt text](./images/argocd-add-repo.png)
 
2. Create Application from repo


3. Sync & deploy

 
