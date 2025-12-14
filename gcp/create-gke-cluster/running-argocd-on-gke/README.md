# Part 1: Installing ArgoCD

Before we begin, we need to install **Argo CD** into the newly created **EKS cluster**.

---

## Step 1: Install ArgoCD on EKS Cluster

Open your terminal (already configured to connect to your eks cluster) and run the following commands:
```bash
# 1. Create a dedicated namespace for Argo CD
kubectl create namespace argocd

# 2. Install Argo CD using the official stable manifest
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

You can verify the installation with:

```bash
kubectl get pods -n argocd
```
Result
```text
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          34s
argocd-applicationset-controller-746fdcd449-9kpqv   1/1     Running   0          39s
argocd-dex-server-59546996c4-tg6x9                  1/1     Running   0          39s
argocd-notifications-controller-6d6cfbd5b4-fcrwp    1/1     Running   0          37s
argocd-redis-5d96cc9756-csnw9                       1/1     Running   0          36s
argocd-repo-server-6987f6f54-psqnb                  1/1     Running   0          35s
argocd-server-56f7848885-sxtds                      1/1     Running   0          35s
```

**Disable internal TLS**
To disable internal TLS, we need to pass the --insecure flag to the argocd-server command, this will avoid an internal redirection loop from HTTP to HTTPS. For this, we need to edit the deployment named “argocd-server” and make the following changes
```bash
kubectl get deployment -n argocd
kubectl edit deployment argocd-server -n argocd
```

The container command should change from:
```text
containers:
- args:
  - /usr/local/bin/argocd-server
```

To
```text
containers:
- args:
  - /usr/local/bin/argocd-server
  - --insecure
```

Restart ArgoCD server
```bash
kubectl rollout restart deployment argocd-server -n argocd
```

# Part 2: Logging In to Argo CD

Argo CD is **not exposed to the internet by default** (for security).  
We will use **port forwarding (tunneling)** to access it safely from your local machine.

---

## Step 1: Retrieve the Argo CD Admin Password

Argo CD automatically generates a random admin password.  
Run the following commands:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```

The output is your **admin password**.

