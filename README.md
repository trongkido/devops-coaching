# 📘 DevOps Knowledge Summary: CI/CD, Git Workflow, and GitOps

## 🚀 CI/CD (Continuous Integration / Continuous Delivery / Deployment)

### What is CI/CD?
- **CI (Continuous Integration)**: Developers frequently merge code into a shared repository. Each commit triggers automated builds and tests to detect issues early.
- **CD (Continuous Delivery)**: Code is automatically built, tested, and packaged for release. Deployment to production requires manual approval.
- **CD (Continuous Deployment)**: Every change that passes tests is automatically deployed to production without manual intervention.

### Benefits
- Faster release cycles
- Higher code quality and reliability
- Reduced manual errors
- Quick feedback loop

### Typical CI/CD Pipeline
1. **Source** – Code pushed to Git repository (GitHub, GitLab, etc.)
2. **Build** – Compile source code, build artifacts, container images
3. **Test** – Unit tests, integration tests, security scans
4. **Release** – Package and store artifacts
5. **Deploy** – Deploy to environments (dev, staging, production)
6. **Monitor** – Observe system metrics and logs

---

## 🐙 Git Basics

### Common Commands
- `git init` – Initialize repository
- `git clone <url>` – Clone repository
- `git add <file>` – Stage changes
- `git commit -m "message"` – Save snapshot
- `git status` – Check repository status
- `git log` – Show commit history
- `git diff` – Show changes
- `git push` – Upload local commits to remote
- `git pull` – Fetch + merge changes from remote
- `git fetch` – Download changes without merging

---

## 🌿 Git Workflows

### 1. **Feature Branch Workflow**
- Create a branch for each feature: `git checkout -b feature/my-feature`
- Merge via Pull Request (PR) → `main`
- Keeps main branch stable

### 2. **Gitflow Workflow**
- **Branches:**
  - `main` → production-ready code
  - `develop` → integration branch
  - `feature/*` → new features
  - `release/*` → prepare new releases
  - `hotfix/*` → quick fixes in production
- Suitable for large projects with scheduled releases

### 3. **Forking Workflow**
- Each developer forks the main repo
- Changes submitted via Pull Request
- Popular in open-source projects

---

## 🔄 GitOps

### What is GitOps?
- GitOps is **using Git as the single source of truth for infrastructure and application deployments**.
- Kubernetes manifests, Helm charts, or Terraform files are stored in Git.
- An operator (e.g., Argo CD, Flux) continuously reconciles cluster state with Git.

### Principles of GitOps
1. **Declarative** – Desired system state is defined in Git
2. **Versioned** – All changes are tracked and auditable
3. **Automated** – CI/CD pipelines and GitOps controllers apply changes automatically
4. **Continuous** – System state is constantly reconciled with Git

### GitOps Workflow
1. Developer commits code/config changes to Git
2. CI pipeline builds & tests artifacts
3. CD (GitOps tool) applies changes to Kubernetes
4. GitOps controller continuously ensures cluster matches Git state

### Tools
- **Argo CD**
- **Flux**
- **Jenkins X**
- **Tekton**

---

## ✅ Summary
- **CI/CD** automates integration, testing, and delivery.
- **Git** provides version control for source code and infrastructure.
- **Git Workflows** (Feature Branch, Gitflow, Forking) standardize collaboration.
- **GitOps** extends CI/CD to infrastructure and Kubernetes, making Git the single source of truth.

---

## 📚 References
- [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials)
- [Gitflow Workflow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Flux CD Documentation](https://fluxcd.io/)
