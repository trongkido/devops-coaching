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

### 8. Install terraform
Terraform is distributed as a single binary executable.
The recommended way is to use official package managers when available, or download the binary manually from the official HashiCorp releases page.
Current latest stable version (as of early 2026): 1.14.3
Always check the official site for the newest version: https://developer.hashicorp.com/terraform/install
After installation, verify with:
```bash
terraform -version
# or
terraform version
```

#### On Windows
##### Method 1: Manual Installation (Recommended for latest version)
1. Go to → https://releases.hashicorp.com/terraform/
2. Find the latest version (e.g., 1.14.3) → Download the Windows zip file (e.g: terraform_1.14.3_windows_amd64.zip)
3. Extract the zip file → You will get a single file: terraform.exe
4. Create a new folder, e.g., C:\terraform
5. Move terraform.exe into this folder
6. Add the folder to your system PATH:
  - Right-click This PC → Properties → Advanced system settings → Environment Variables
  - Under System variables, find and edit Path
  - Add new entry: C:\terraform (or wherever you placed it)
  - Click OK on all windows
7. Open a new Command Prompt or PowerShell and verify:
```bash
terraform -version
```

##### Method 2: Using Chocolatey (Package Manager)
If you already have Chocolatey installed:
```bash
# Run in PowerShell (Administrator)
choco install terraform
# or to upgrade:
choco upgrade terraform
```

#### On MacOS
Recommended Method: Homebrew (Official HashiCorp tap)
1. Make sure you have Homebrew installed (brew --version)
  - If not: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

2. Add the official HashiCorp tap and install:
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

3. (Optional) To upgrade later:
```bash
brew upgrade hashicorp/tap/terraform
```

Alternative: Manual Binary Installation
1. Go to → https://releases.hashicorp.com/terraform/
2. Download the file for your architecture:
  - Apple Silicon (M1/M2/M3...): terraform_1.14.3_darwin_arm64.zip
  - Intel: terraform_1.14.3_darwin_amd64.zip

3. Unzip the file
4. Move the binary to a directory in your PATH:
```bash
unzip terraform_*.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
```

4. Verify
```bash
terraform version
```

#### On Linux
Recommended: Official HashiCorp APT/YUM Repository (Debian/Ubuntu or RHEL/Fedora)
For Ubuntu / Debian
```bash
# Install prerequisites
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# Add the official repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install
sudo apt update
sudo apt install terraform
```

For RHEL / CentOS / Fedora / Amazon Linux
```bash
# RHEL / CentOS
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform

# Fedora
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
sudo dnf -y install terraform
```

Manual Binary Installation (Any Linux distro)
1. Go to → https://releases.hashicorp.com/terraform/

2. Choose correct architecture (most common: amd64 or arm64). Example: terraform_1.14.3_linux_amd64.zip

3. Download and install:
```bash
wget https://releases.hashicorp.com/terraform/1.14.3/terraform_1.14.3_linux_amd64.zip
unzip terraform_1.14.3_linux_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
```
4. Verify
```bash
terraform -version
```

**Quick Tips**
  - Always prefer official repositories or manual download for the very latest version.
  - Use tools like tfenv or asdf if you need multiple Terraform versions on the same machine.
  - After installation, run terraform -version in a new terminal window to confirm success.
