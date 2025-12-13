# Amazon Elastic Container Registry (ECR) Summary

Amazon Elastic Container Registry (ECR) is a fully managed, secure, scalable, and reliable container image registry service provided by AWS. It allows developers to store, manage, and deploy Docker and Open Container Initiative (OCI) images and artifacts. ECR supports both **private** and **public** repositories.

## Overview

- **Private Registry**: Each AWS account gets a default private registry for storing images securely within your AWS environment.
- **Public Registry** (Amazon ECR Public): A separate service for hosting publicly accessible images, including a public gallery for discovering images from vendors, open-source projects, and the community.
- ECR integrates seamlessly with AWS services like Amazon ECS, EKS, Lambda, Fargate, and CI/CD tools (e.g., CodeBuild, CodePipeline).
- Images are stored in Amazon S3 for high durability (11 9's).
- Supports Docker CLI and OCI standards.

## Key Features

- **Security**:
  - Encryption at rest (default SSE-S3; optional KMS).
  - Encryption in transit (HTTPS).
  - IAM resource-based permissions for fine-grained access control.
  - Image vulnerability scanning (basic or enhanced with Amazon Inspector for OS and language packages).
- **Management**:
  - Image tagging and versioning.
  - Lifecycle policies: Automate cleanup/expiration/archival of images based on rules (e.g., age, count, tag status, last pull time).
  - Tag immutability to prevent overwriting.
- **Replication**:
  - Cross-Region and cross-account replication for high availability and low-latency pulls.
- **Pull-Through Cache**: Cache public upstream registries (e.g., Docker Hub, Quay.io) in your private ECR.
- **High Availability**: Multi-AZ architecture; supports thousands of concurrent pushes/pulls.
- **New (2025)**: Archive storage class for rarely accessed images (cost-optimized long-term storage; requires restore before pull).
- **Other**: Repository creation templates, namespace organization.

## Pricing

ECR has **no upfront fees or commitments**. You pay only for storage and data transfer out to the internet.

### Storage
- **Standard Storage** (active images): $0.10 per GB/month (private or public repositories).
- **Archive Storage** (new in 2025, for rarely accessed images): Lower cost (exact rate: refer to official pricing page as it may vary).
- Storage billed to the repository owner.

### Data Transfer
- **In** (pushes): Free.
- **Out within same Region** (e.g., to EC2, ECS, EKS in same region): Free.
- **Out to internet** (private repositories): Standard AWS data transfer rates (aggregated across services; often first 1 GB/month free, then tiered ~$0.09/GB).
- Cross-Region replication: Charges apply based on source region rates.

### Public Repositories Specific
- Out to internet: 
  - Anonymous pulls: 500 GB/month free.
  - Authenticated (with AWS account): 5 TB/month free.
  - Excess: ~$0.09/GB.

### Free Tier
- New customers: 500 MB/month private storage free for 12 months.

**Note**: Pricing can vary by region. For the latest details and examples, visit the official AWS ECR Pricing page: https://aws.amazon.com/ecr/pricing/

## How to Create and Push Docker Image to AWS ECR Step by Step

### Prerequisites
- An existing Amazon ECR repository (create it if needed; see [Creating an Amazon ECR private repository to store images](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html)).
- AWS CLI installed and upgraded to the latest version (see [Installing the AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)).
- Docker client installed.
- IAM permissions required for pushing images (e.g., AmazonEC2ContainerRegistryPowerUser policy).
- A Dockerfile and application code to build the image.

### Step-by-Step Guide

1. **Build the Docker Image Locally**  
Navigate to the directory containing your Dockerfile and application code. Build the image using the Docker CLI.  
```bash
docker build -t my-image:tag .
```
Replace my-image:tag with your desired image name and tag (e.g., hello-world:latest).
The . specifies the current directory as the build context.

2. **Authenticate Docker Client to Amazon ECR Registry**
Run the aws ecr get-login-password command to obtain an authentication token (valid for 12 hours). Use AWS as the username and the ECR registry URI.
```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
```
Replace <region> with your AWS region (e.g., us-west-2).
Replace <aws_account_id> with your 12-digit AWS account ID.
Repeat for each registry if using multiple.

3. **Create the ECR Repository (if not already done)**
Use the AWS CLI to create a private repository:
```bash
aws ecr create-repository --repository-name my-repository --region <region>
```
Replace my-repository with your desired repository name.
This command returns the repository URI, which you'll use for tagging and pushing.

4. **Identify the Local Docker Image**
List local images to find the image ID or repository:tag.
```bash
docker images
```

5. **Tag the Image for Amazon ECR**
Tag the local image with the ECR registry URI, repository name, and optional tag (defaults to latest if omitted).
Example:
```bash
docker tag my-image:tag <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-repository:tag
```
<aws_account_id>.dkr.ecr.<region>.amazonaws.com is the registry URI.
my-repository:tag is the repository and tag name.

6. **Push the Image to ECR**
Use the docker push command with the tagged image.
```bash
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-repository:tag
```

7. **(Optional) Apply and Push Additional Tags**
Repeat steps 5 and 6 for any additional tags you want to apply and push.

8. **Verify the Push**
Check the repository in the AWS Management Console or using the AWS CLI:
```bash
aws ecr describe-images --repository-name my-repository --region <region>
```

## Benefits and Best Practices

- **Benefits**:
  - Fully managed (no infrastructure to scale or maintain).
  - Seamless AWS integration for streamlined workflows.
  - Cost-effective with pay-for-what-you-use model.
  - Enhanced security and compliance.
- **Best Practices**:
  - Use lifecycle policies to delete old/unused images and reduce costs.
  - Enable enhanced scanning and act on findings.
  - Use replication for global/multi-region deployments.
  - Implement least-privilege IAM policies.
  - Archive inactive images for long-term retention.
  - Monitor costs via AWS Cost Explorer.

## Resources
- Official Documentation: https://docs.aws.amazon.com/AmazonECR/
- User Guide: https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html
- Public ECR: https://docs.aws.amazon.com/AmazonECR/latest/public/what-is-ecr.html
