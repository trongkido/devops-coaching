# AWS Starter Guide – Free Tier, IAM, Access Keys & AWS CLI

---

## 📑 Table of Contents
[Introduction to AWS](#introduction-to-aws)

[AWS Basic Services](#aws-basic-services)

[Create an AWS Free Tier Account (Step-by-Step)](#create-an-aws-free-tier-account-step-by-step)

[Create an IAM User Account](#create-an-iam-user-account)

[Create Access Keys for IAM User](#create-access-keys-for-iam-user)

[Install & Configure AWS CLI](#install--configure-aws-cli)

[Summary](#summary)

[References](#references)

---

## Introduction to AWS

**Amazon Web Services (AWS)** is the world’s most widely used **cloud platform**, providing more than 200 fully featured services. AWS offers tools to build scalable applications, store data, deploy infrastructure, manage security, and automate workloads using cloud technologies.

## AWS Basic Services

| Service | Purpose | Category |
|---|---|---|
| **EC2 (Elastic Compute Cloud)** | Virtual servers / compute instances | Compute |
| **S3 (Simple Storage Service)** | Object storage (files, backups, static hosting) | Storage |
| **RDS (Relational Database Service)** | Managed SQL databases (MySQL, PostgreSQL, Oracle, SQL Server) | Database |
| **VPC (Virtual Private Cloud)** | Virtual private network / subnet, routing, isolation | Networking |
| **IAM (Identity & Access Management)** | Users, permissions, roles, access policies | Security |
| **Lambda** | Serverless compute, run code without servers | Compute / Serverless |
| **CloudWatch** | Logs, monitoring, dashboards, alerts | Monitoring |
| **EBS (Elastic Block Store)** | Persistent block storage for EC2 | Storage |
| **DynamoDB** | NoSQL managed key-value & document DB | Database / NoSQL |
| **SNS (Simple Notification Service)** | Send notifications (email, SMS, webhooks, alerts) | Messaging |
| **SQS (Simple Queue Service)** | Message queueing, decoupling components | Messaging |
| **Route 53** | DNS & domain routing | Networking |
| **CloudFormation** | Infrastructure as Code for AWS | IaC / Automation |

---

## 🚀 Create an AWS Free Tier Account (Step-by-Step)

Follow these steps to register an AWS account under Free Tier:

### ✅ Step 1: Sign Up
1. Visit the AWS sign up page.
2. Enter:
   - Email address
   - AWS account name
   - Root password
3. Verify the email using OTP sent by AWS.

### 💳 Step 2: Billing Info
- Enter personal or company billing address.
- Add a valid credit/debit card (required for verification, but not charged for Free Tier usage).

### 👤 Step 3: Identity Verification
- Choose SMS or Call for verification.
- Enter OTP received on your phone.

### 📉 Step 4: Choose Support Plan
- Select **Basic Support (Free)**.

### 🎉 Step 5: Access the Console
- Login to AWS Console using the **Root Email & Password**.

> ⚠ Best Practice: **Never use root account for daily work**, always create IAM users.

---

## 🔐 Create an IAM User Account

### 👥 Step 1: Open IAM Service
1. Go to AWS Console → Search **IAM** → Open it.

### 🧑 Step 2: Create User
1. Click **Users** → **Create User**
2. Enter username (example: `devops-admin`)
3. Select:
   - ✅ **Provide user access to AWS Management Console**
4. Choose:
   - **I want to create an IAM user** (or custom password)
   - Optional: **Require password reset on first login**

### 🛡 Step 3: Assign Permissions
You have 3 options (use 1 of them):

| Method | Recommendation |
|---|---|
| **Add user to group** | ✅ Best practice |
| **Attach policies directly** | ⚠ OK but not ideal |
| **Copy permissions from existing user** | ⚠ Only if cloning |

Steps:
1. Choose **Create Group**
2. Select policy:
   - `AdministratorAccess` (for full access)
3. Assign user to that group.

### 📌 Step 4: Create user
- Save the IAM console URL shown after creation.

---

## 🔑 Create Access Keys for IAM User

1. Go to IAM → Users → select your user
2. Open **Security Credentials** tab
3. Scroll to **Access keys** → **Create Access Key**
4. Choose use case:
   - `Command Line Interface (CLI)`
5. Create → Download `.csv` or copy:
   - `Access Key ID`
   - `Secret Access Key`

> ⚠ You can only view Secret Key **once**. Store it securely.

---

## 💻 Install & Configure AWS CLI

### 🏗 Step 1: Install AWS CLI
```bash
# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# macOS (via Homebrew)
brew install awscli

# Windows (PowerShell)
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

Check version:

``` bash
aws --version
```

### ⚙ Step 2: Configure AWS CLI Profile
``` bash
aws configure
```

Then fill out information
```text
Access Key ID: <YOUR_KEY>
Secret Access Key: <YOUR_SECRET>
Region: ap-southeast-1
Output: json
```

### ✅ Step 3: Test CLI Authentication
``` bash
aws sts get-caller-identity
```

## Summary

✅ AWS root account created
✅ IAM user created
✅ Access keys generated
✅ AWS CLI installed and configured

## References
[aws-overview]: https://aws.amazon.com/what-is-aws/
[aws-free-tier]: https://aws.amazon.com/free/
[iam-guide]: https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html
[iam-best-practices]: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html
[iam-access-keys]: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html
[aws-cli-install]: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
[aws-cli-configure]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html
[aws-cli-sts]: https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html
[aws-ec2]: https://docs.aws.amazon.com/ec2/
[aws-s3]: https://docs.aws.amazon.com/s3/
[aws-rds]: https://docs.aws.amazon.com/rds/
[aws-vpc]: https://docs.aws.amazon.com/vpc/
[aws-lambda]: https://docs.aws.amazon.com/lambda/
[aws-cloudwatch]: https://docs.aws.amazon.com/cloudwatch/
[aws-cloudformation]: https://docs.aws.amazon.com/cloudformation/
[aws-sns]: https://docs.aws.amazon.com/sns/
[aws-sqs]: https://docs.aws.amazon.com/sqs/
