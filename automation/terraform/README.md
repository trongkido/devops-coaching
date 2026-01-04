# Terraform: What is it? Why use it? When should you use it?

🟣 Terraform Navigation
1. Definition  
|  
2. History  
|  
3. ClickOps vs IaC  
|  
4. Declarative  
|  
5. Workflow  
|  
6. Code  

## 1. Terraform: Infrastructure as Code  

As we know, Terraform is often compared to a “Construction Team”. Today, we will learn how this team works.

### 🟣 Short Definition:
Terraform is an open-source tool that allows you to define infrastructure (Server, Network, DNS, DB…) using **CODE** instead of manual mouse clicks.

### 2. The Origin Story
Why was Terraform created when AWS already had CloudFormation?

🕰️ Before 2014: The Era of Chaos  
- **Vendor Lock-in**: To work with AWS, you had to learn CloudFormation's JSON. For Azure, you had to learn ARM Templates.  
- **Hard-to-read languages**: JSON/XML is verbose, no support for comments, difficult to maintain.  
- **Fragmented**: No tool could manage both Cloud and On-Premise (VMware) at the same time.  

🚀 2014: The Birth of Terraform  
Mitchell Hashimoto (Founder of HashiCorp) wanted to create a “common language” (Lingua Franca) for infrastructure.  

- **Cloud Agnostic**: Write code in one style, usable for AWS, Google, Azure, VMware.  
- **HCL (HashiCorp Configuration Language)**: A configuration language designed to be human-readable, not just machine-readable.  

> “Terraform does not try to hide the differences between clouds; it provides a unified workflow to manage them.”

### 3. Why use it? (The Pain of ClickOps)
Before Terraform, we worked in “ClickOps” style (Click Workers). Let's see the differences:

❌ **Old Way (ClickOps)**  
- High risk: Accidentally delete the production DB? Disaster.  
- Inconsistent: Dev environment one way, Prod another.  
- No documentation: When the SysAdmin quits, the whole team is lost.  
- Slow: Disaster Recovery takes weeks.  

✅ **New Way (Terraform)**  
- Version Control: Stored in Git. Everyone knows who changed what.  
- Speed: Provision 100 servers in 5 minutes.  
- Self-documenting: Read the code and understand the architecture.  
- Review: Boss reviews the code before running commands.  

### 4. Mindset: Imperative vs Declarative
This is the most important part to understand Terraform. It's completely different from Bash scripts.

🚗 **Example: You want to take a taxi to the Airport**  

**Imperative (Bash/Python)**  
“Give step-by-step commands”:  
- Go straight 500m.  
- Turn left at the intersection.  
- If traffic jam, turn right.  
- Stop at gate number 1.  

**Declarative (Terraform)**  
“Declare the desired outcome”:  
“I want to go to the Airport.”  
(The driver figures out the optimal route himself)  

👉 Terraform is **Declarative**. You just declare: “I want 3 Ubuntu servers”. Terraform automatically calculates what needs to be created or modified to reach exactly 3.

### 5. How it Works (The Workflow)
The standard workflow of a DevOps Engineer with Terraform consists of 3 steps:

✍️ **Write**  
Write code defining the infrastructure (`.tf` files).  

➡️  

🔍 **Plan**  
Dry-run. Compare Code vs Reality.  
“It will create 2, delete 1”  

➡️  

🚀 **Apply**  
Approve. Call the Cloud APIs to execute.  

### 6. Reading Code (HCL Syntax)
Terraform uses the HCL language. It's very easy to read, almost like English.

📄 **main.tf**
```hcl
# 1. Declare Provider (The platform you want to use)
provider "aws" {
  region = "us-east-1"
}

# 2. Declare Resource (Resources to create)
# Syntax: resource "resource_type" "name_in_code"
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # ID of Ubuntu image
  instance_type = "t2.micro"                # CPU/RAM configuration
  tags = {
    Name = "Tony-Web-01"
  }
}
```
With just these few lines, you replace dozens of manual clicks on the Console.

### 7. When should & should NOT use it?
✅ SHOULD USE WHEN:

Production systems that require stability.
Teamwork, need code reviews.
Complex systems, multi-platform (Hybrid Cloud).
Need consistent environments (Dev = Staging = Prod).

🚫 SHOULD NOT USE WHEN:

Quick experiments (POC) used once and discarded.
Deep OS internal configuration management (Create users, config files) → Use Ansible instead!
Very small systems, just 1 server that never changes.
