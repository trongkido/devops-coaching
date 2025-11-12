# 📘 DevOps Knowledge Summary: ArgoCD Overview and Concepts

This repository contains notes, exercises, and lab materials for learning **ArgoCD** — from installation and basic operation to advanced pipeline automation techniques.

---

## 📑 Table of Contents
1. [🚀 ArgoCD?](#-argocd)
  - [What is ArgoCD?](#what-is-ArgoCD)
  - [ArgoCD vs Jenkins](#argocd-vs-jenkins)

2. [📚 References](#-references)  

---

## 1. ArgoCD?
### What is ArgoCD?

Argo CD is described as “a declarative, GitOps continuous delivery tool for Kubernetes.” It can monitor your source repositories and automatically deploy changes to your cluster.

![Alt text](./images/argocd_introduce.jpg)

Kubernetes orchestrates container deployment and management tasks. It starts your containers, replaces them when they fail, and scales your service across the compute nodes in your cluster.

Kubernetes is best used as part of a continuous delivery workflow. Running automated deployments when new code is merged ensures changes reach your cluster quickly after passing through a consistent pipeline.
Please refer to https://spacelift.io/blog/kubernetes-tutorial if you're new about kubernetes

Key features of Argo CD include:

*   **GitOps-based deployment** – Uses Git as the single source of truth, enabling declarative configuration and automated syncing with Kubernetes clusters
*   **Declarative application definitions** – Supports Helm, Kustomize, Jsonnet, and plain YAML to define and manage application manifests
*   **Automated synchronization** – Automatically syncs Kubernetes resources with Git repositories, ensuring cluster state matches the desired state
*   **Real-time application status monitoring** – Continuously monitors app health and sync status, with visual dashboards and diff views
*   **Role-based access control (RBAC)** – Fine-grained access controls for managing user permissions across projects and environments
*   **Multi-cluster support** – Manages deployments across multiple Kubernetes clusters from a single Argo CD instance
*   **Web UI and CLI**– Provides a user-friendly web interface and CLI for managing applications, viewing diffs, and troubleshooting

Argo CD is easy to learn once you understand its basic concepts. Here are the core elements of Argo CD architecture:

*   **Application controller** – Argo’s Application Controller is the component you install in your cluster. It implements the Kubernetes controller pattern to monitor your applications and compare their state against their repositories.
*   **Application** – An Argo application is a group of Kubernetes resources that collectively deploy your workload. Argo stores the details of applications in your cluster as instances of an included Custom Resource Definition (CRD).
*   **Live state** – The live state is your application’s current state inside the cluster, such as the number of Pods created and the image they’re running.
*   **Target state** – The target state is the version of the state declared by your Git repository. When the repository changes, Argo will apply actions that evolve the live state into the target state.
*   **Refresh** – A refresh occurs when Argo fetches the target state from your repository. It compares the changes against the live state but doesn’t necessarily apply them at this stage.
*   **Sync** – A Sync is the process of applying the changes discovered by a Refresh. Each Sync moves the cluster back toward the target state.
*   **API server** – The Argo API server provides the REST and gRPC API interface used by the CLI, Web UI, and external integrations.
*   **Git repository** – The Git repository acts as the single source of truth, storing declarative configurations for all applications and environments.



