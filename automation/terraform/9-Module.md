# Terraform Modules -- Complete Guide

## 1. What is a Terraform Module?

A **Terraform Module** is a container for multiple resources that are used together. Modules allow you to **organize Terraform code, reuse infrastructure components, and maintain clean Infrastructure as Code (IaC)**.

In Terraform, **every Terraform configuration is technically a module**: - The **root module**: the main working directory where you run Terraform commands. - **Child modules**: modules called by the root module or other modules.

Using modules helps standardize infrastructure deployment and enables code reuse.

------------------------------------------------------------------------

# 2. Why Use Terraform Modules?

Benefits of using modules:

### 2.1 Reusability

Write infrastructure logic once and reuse it multiple times.

Example: - VPC module - Kubernetes cluster module - Security group module

### 2.2 Maintainability

Instead of one large Terraform configuration, modules break infrastructure into smaller manageable components.

### 2.3 Standardization

Teams can enforce best practices by publishing standardized modules.

### 2.4 Collaboration

Different teams can work on different modules.

### 2.5 Abstraction

Hide complex infrastructure logic behind a simple interface.

------------------------------------------------------------------------

# 3. Types of Terraform Modules

## 3.1 Root Module

The directory where Terraform commands are executed.

Example:

    terraform init
    terraform plan
    terraform apply

Typical structure:

    project/
      main.tf
      variables.tf
      outputs.tf
      terraform.tfvars

------------------------------------------------------------------------

## 3.2 Child Modules

Modules called from another module.

Example:

    module "vpc" {
      source = "./modules/vpc"

      cidr_block = "10.0.0.0/16"
    }

------------------------------------------------------------------------

## 3.3 Local Modules

Modules stored locally in the repository.

Example:

    source = "./modules/network"

------------------------------------------------------------------------

## 3.4 Remote Modules

Modules stored in remote locations:

Examples:

### Terraform Registry

    source = "terraform-aws-modules/vpc/aws"

### Git Repository

    source = "git::https://github.com/org/module.git"

### Git with version

    source = "git::https://github.com/org/module.git?ref=v1.0.0"

### S3 bucket

    source = "s3::https://s3.amazonaws.com/bucket/module.zip"

------------------------------------------------------------------------

# 4. Terraform Module Structure

A well-designed module typically follows this structure:

    modules/
      vpc/
        main.tf
        variables.tf
        outputs.tf
        versions.tf
        README.md
        examples/

### File descriptions

  File           Purpose
  -------------- ---------------------------------
  main.tf        Main resource definitions
  variables.tf   Input variables
  outputs.tf     Outputs exported from module
  versions.tf    Terraform and provider versions
  README.md      Documentation

------------------------------------------------------------------------

# 5. Input Variables

Modules accept inputs via variables.

Example:

    variable "instance_type" {
      description = "EC2 instance type"
      type        = string
    }

Using variables:

    resource "aws_instance" "example" {
      instance_type = var.instance_type
    }

Calling module:

    module "ec2" {
      source = "./modules/ec2"

      instance_type = "t3.micro"
    }

------------------------------------------------------------------------

# 6. Output Values

Modules expose outputs for other modules or root module.

Example:

    output "instance_id" {
      value = aws_instance.example.id
    }

Access output:

    module.ec2.instance_id

------------------------------------------------------------------------

# 7. Module Versioning

Versioning ensures consistent deployments.

Example with Terraform Registry:

    module "vpc" {
      source  = "terraform-aws-modules/vpc/aws"
      version = "5.1.0"
    }

Benefits:

-   Prevent breaking changes
-   Reproducible infrastructure
-   Controlled upgrades

------------------------------------------------------------------------

# 8. Module Composition

Modules can call other modules.

Example:

    module "network" {
      source = "./modules/network"
    }

    module "compute" {
      source = "./modules/compute"
    }

Architecture example:

    root module
     ├── networking module
     ├── security module
     └── compute module

------------------------------------------------------------------------

# 9. Best Practices for Terraform Modules

### 9.1 Keep modules small

Each module should represent a single infrastructure component.

### 9.2 Use clear variable names

Bad:

    var.x

Good:

    var.instance_type

### 9.3 Add descriptions

Always document variables and outputs.

### 9.4 Use version constraints

Example:

    required_version = ">= 1.5.0"

### 9.5 Avoid hardcoded values

Use variables.

### 9.6 Provide examples

Include example usage for easier adoption.

------------------------------------------------------------------------

# 10. Terraform Module Registry

Terraform Registry is the official module repository.

Popular modules:

-   AWS VPC module
-   AWS EKS module
-   Kubernetes module

Website: https://registry.terraform.io

Example usage:

    module "vpc" {
      source = "terraform-aws-modules/vpc/aws"
    }

------------------------------------------------------------------------

# 11. Example Terraform Module

## Module Structure

    modules/ec2/
      main.tf
      variables.tf
      outputs.tf

### variables.tf

    variable "instance_type" {
      type = string
    }

### main.tf

    resource "aws_instance" "example" {
      ami           = "ami-123456"
      instance_type = var.instance_type
    }

### outputs.tf

    output "instance_id" {
      value = aws_instance.example.id
    }

------------------------------------------------------------------------

# 12. Testing Terraform Modules

Tools for testing modules:

-   terraform validate
-   terraform plan
-   Terratest (Go)
-   Kitchen-Terraform

Example:

    terraform validate

------------------------------------------------------------------------

# 13. Terraform Module vs Terraform Workspace

  Feature   Module
  --------- --------------------------
  Purpose   Code reuse
  Scope     Infrastructure component
  Example   VPC module

------------------------------------------------------------------------

# 14. Real-World DevOps Example

Typical enterprise Terraform structure:

    terraform-live/
      dev/
        main.tf
      prod/
        main.tf

    terraform-modules/
      vpc/
      eks/
      rds/

Advantages:

-   Clear separation between environments
-   Reusable infrastructure modules
-   Easier CI/CD automation

------------------------------------------------------------------------

# 15. Summary

Terraform modules are one of the most powerful features of Terraform.

Key takeaways:

-   Modules enable **reusable infrastructure**
-   Support **team collaboration**
-   Encourage **clean architecture**
-   Simplify **large-scale infrastructure deployments**

Recommended approach:

1.  Build reusable modules
2.  Version modules
3.  Store modules in Git or Terraform Registry
4.  Use modules across multiple environments

------------------------------------------------------------------------
