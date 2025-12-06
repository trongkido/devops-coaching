# Step-by-Step Guide: Creating an EKS Cluster with eksctl

---

## 📑 Table of Contents

[Introduction to EKS](#introduction-to-eks)

[Prerequisites](#prerequisites)

[Create IAM Roles](#create-iam-roles)

[Create EC2 Key Pair](#create-ec2-key-pair)

[Install eksctl](#install-eksctl)

[Create the EKS Cluster](#create-the-eks-cluster)

[Summary](#summary)

[References](#references)

---

## Introduction to Amazon EKS

Amazon Elastic Kubernetes Service (EKS) is a fully managed Kubernetes service that makes it easy to run Kubernetes on AWS without needing to manage your own control plane or nodes.

## Prerequisites

Before creating your EKS cluster, ensure you have:
- An AWS account
- IAM admin permissions
- AWS CLI installed
- kubectl installed
- eksctl installed

## Create IAM Roles
### Create Cluster Role
You need to create 2 roles, EKS Cluster Role and EKS Worker Role.
First, we will create EKS Cluster Role
On "IAM Access management", choose "Role", Click "Create role"
![Alt text](./images/iam-create-role.png)

On "Trusted entity type", choose "AWS service", in "Use case" choose "EKS- Cluster", click "Next"
![Alt text](./images/iam-create-role-step2.png)

Click "Next" in "Step 2: Add permissions"
![Alt text](./images/iam-create-role-step3.png)

Fill out the "Role Name" and click "Create role"
![Alt text](./images/iam-create-role-step4.png)

### Create Worker Role
Next, we need to create EKS Worker Role
On "Trusted entity type", choose "AWS service", in "Use case" choose "EC2", click "Next"
![Alt text](./images/iam-create-worker-role.png)

In "Step 2: Add permissions", add these 3 permissions
- AmazonEKSWorkerNodePolicy
- AmazonEC2ContainerRegistryReadOnly
- AmazonEKS_CNI_Policy
![Alt text](./images/iam-create-worker-role-step2.png)

Fill out the "Role Name" and click "Create role"
![Alt text](./images/iam-create-worker-role-step4.png)

You can check the role after created by searching in IAM Roles
![Alt text](./images/iam-create-role-success.png)

## Create EC2 Key Pair
On "EC2 Network & Security" screen, choose "Key Pairs" and click "Create key pair"
![Alt text](./images/key-pair-create.png)

Then proceed to set:
Name: The name of the key. Remember this name, as it will be used later in the creation script.
Key pair type: Select RSA
Private key file format: .pem
Click Create key pair to generate the key
![Alt text](./images/key-pair-create-step2.png)

Key pair create successfully
![Alt text](./images/key-pair-create-success.png)

## Install eksctl
### macOS

``` bash
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
```

### Linux

``` bash
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz"
tar -xzf eksctl_$(uname -s)_amd64.tar.gz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

### Windows (PowerShell)

``` powershell
choco install eksctl
```

## Create the EKS Cluster

