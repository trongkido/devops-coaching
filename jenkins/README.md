# 📘 DevOps Knowledge Summary: Jenkins Overview and Concepts

This repository contains notes, exercises, and lab materials for learning **Jenkins** — from installation and basic operation to advanced pipeline automation techniques.

---

## 📑 Table of Contents
1. [🚀 Jenkins?](#-jenkins)
  - [What is Jenkins?](#what-is-jenkins)
  - [Gitlab vs Jenkins](#gitlab-vs-jenkins)
  - [Master-Agent architecture](#master-agent-architecture)

2. [📚 References](#-references)  

---

## 1. Jenkins?
### What is Jenkins?

Jenkins is one of the most popular **open-source automation servers** used to build, test, and deploy software.  
It helps DevOps teams implement **Continuous Integration (CI)** and **Continuous Delivery (CD)** processes efficiently.

With Jenkins, you can:
- Automate repetitive tasks such as building, testing, and deploying code.
- Integrate with hundreds of developer tools (Git, Docker, Kubernetes, Slack, etc.).
- Scale workloads across multiple machines using its distributed build architecture.

Jenkins enables teams to **deliver software faster**, with **greater reliability**, and **fewer manual steps**.

Jenkins acts as the **automation hub** in a DevOps workflow.  
It can pull source code from repositories, run build pipelines, execute automated tests, and deploy applications.

#### Key Features:
- **Extensible:** Over 1,800 plugins for integrating with almost any technology.
- **Pipeline as Code:** Define workflows using a `Jenkinsfile`.
- **Open Source:** Completely free and supported by an active community.
- **Cross-Platform:** Works on Linux, Windows, and macOS.
- **Scalable:** Supports distributed builds through agents and nodes.

#### Example Jenkinsfile (Declarative Syntax)
```groovy
pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        echo 'Building application...'
      }
    }
    stage('Test') {
      steps {
        echo 'Running tests...'
      }
    }
    stage('Deploy') {
      steps {
        echo 'Deploying to production...'
      }
    }
  }
}
```

---

### GitLab vs Jenkins

Both **GitLab CI/CD** and **Jenkins** are popular automation tools in DevOps pipelines — but they differ in ecosystem, setup, and flexibility.

| **Feature** | **Jenkins** | **GitLab CI/CD** |
|--------------|--------------|------------------|
| **Type** | Standalone automation server | Built-in CI/CD feature in GitLab |
| **Setup** | Requires manual installation & plugin configuration | Comes pre-integrated with GitLab |
| **Pipeline Definition** | `Jenkinsfile` (Groovy syntax) | `.gitlab-ci.yml` (YAML syntax) |
| **Integration** | Integrates with any VCS (GitHub, Bitbucket, GitLab, SVN, etc.) | Natively supports only GitLab repositories |
| **Scalability** | Highly flexible; can connect multiple agents/nodes | Scales within GitLab Runner environment |
| **Plugin System** | 1,800+ plugins; extremely customizable | Limited to GitLab features & runners |
| **Ease of Use** | Steeper learning curve | Easier for GitLab users; simpler UI |
| **Best For** | Complex, large-scale, multi-platform CI/CD | Teams already using GitLab for source control |

#### Summary

- Choose **Jenkins** if you want **maximum flexibility**, **cross-platform support**, and **fine-grained control**.  
- Choose **GitLab CI/CD** if your team already uses **GitLab repositories** and you prefer **simplicity over flexibility**.

---

### Master-Agent Architecture

Jenkins uses a **Master-Agent (Controller-Node)** architecture to distribute workload and improve scalability.

---

#### Components

##### Master (Controller)
- The central brain of Jenkins.  
- Manages job scheduling, plugin management, and configuration.  
- Delegates build jobs to available agents.

##### Agent (Node)
- Executes build jobs assigned by the master.  
- Can run on different machines or environments (e.g., Docker, Kubernetes, Linux, Windows).  
- Reports build status and logs back to the master.

##### Executor
- A logical slot within an agent that runs a single build at a time.  
- Each agent can have one or more executors depending on system capacity.

#### Architecture Diagram (Text Overview)
             +----------------------+
             |      Jenkins Master   |
             |-----------------------|
             |  - Job Scheduling     |
             |  - UI & Configuration |
             |  - Plugin Management  |
             +----------+------------+
                        |
                        | (via SSH, JNLP, HTTP)
                        |
   +--------------------+--------------------+
   |                    |                    |
+------+            +--------+           +--------+
|Agent1|            |Agent2 |           |Agent3 |
|Build |            |Docker |           |K8s Pod|
+------+            +--------+           +--------+

## 2. References
- [Tony Tech Lab - Jenkins Course](https://tonytechlab.com/courses/mastering-ci-cd-from-docker-to-k8s/lessons/1-3-1-ly-thuyet-jenkins-la-gi-kien-truc-master-agent/)
- [Jenkins Official Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Blue Ocean Plugin](https://plugins.jenkins.io/blueocean/)
- [Jenkins on DockerHub](https://hub.docker.com/_/jenkins)
