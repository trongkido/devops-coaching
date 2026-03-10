# Terraform Import -- Complete Guide

## 1. What is Terraform Import?

**Terraform Import** allows you to bring **existing infrastructure resources** under Terraform management **without recreating them**.

Normally Terraform creates infrastructure using:

    terraform apply

But many real-world environments already have infrastructure created manually or by other tools.
Terraform Import allows you to **map those existing resources to Terraform state**.

Key idea:

Terraform Import **adds the resource to the Terraform state**, but **does NOT generate Terraform configuration automatically**.

You must still write the `.tf` configuration manually.

------------------------------------------------------------------------

# 2. Why Terraform Import is Important

Terraform Import is useful when:

  Situation                 Example
  ------------------------- --------------------------------------
  Existing infrastructure   AWS resources created manually
  Migration to Terraform    Moving from manual management to IaC
  Multi-team environments   Other teams created resources
  Disaster recovery         Rebuild Terraform state
  Terraform state lost      Recover infrastructure control

Example:

You already have:

-   AWS EC2 instances
-   VPC networks
-   RDS databases

Instead of deleting and recreating them, you can **import them into Terraform**.

------------------------------------------------------------------------

# 3. Terraform Import Workflow

Typical workflow:

    Existing Infrastructure
            ↓
    Write Terraform configuration
            ↓
    terraform import
            ↓
    Terraform state updated
            ↓
    terraform plan
            ↓
    Terraform manages resource

Steps:

1.  Write resource configuration
2.  Run `terraform import`
3.  Run `terraform plan` to validate

------------------------------------------------------------------------

# 4. Basic Terraform Import Syntax

    terraform import RESOURCE_ADDRESS RESOURCE_ID

Example:

    terraform import aws_instance.example i-1234567890abcdef0

Explanation:

  Element            Meaning
  ------------------ -------------------------------
  RESOURCE_ADDRESS   Terraform resource name
  RESOURCE_ID        Provider-specific resource ID

------------------------------------------------------------------------

# 5. Example: Import AWS EC2 Instance

## Step 1 -- Write Terraform Resource

    resource "aws_instance" "example" {
      ami           = "ami-0c02fb55956c7d316"
      instance_type = "t2.micro"
    }

## Step 2 -- Import Resource

    terraform import aws_instance.example i-0abcd1234efgh5678

Terraform output example:

    aws_instance.example: Importing from ID "i-0abcd1234efgh5678"...
    Import successful!

------------------------------------------------------------------------

# 6. Importing AWS S3 Bucket

Configuration:

    resource "aws_s3_bucket" "my_bucket" {
      bucket = "my-existing-bucket"
    }

Import command:

    terraform import aws_s3_bucket.my_bucket my-existing-bucket

------------------------------------------------------------------------

# 7. Importing Modules

Terraform Import also supports modules.

Example:

    module.network.aws_vpc.main

Command:

    terraform import module.network.aws_vpc.main vpc-123456

------------------------------------------------------------------------

# 8. Checking Imported Resources

After importing, run:

    terraform plan

Purpose:

-   Compare configuration vs actual resource
-   Identify missing attributes

Often Terraform will show differences because the `.tf` configuration may not match the real resource.

------------------------------------------------------------------------

# 9. Terraform State After Import

Terraform Import updates the **state file**.

Example:

    terraform.tfstate

State now contains:

    aws_instance.example

You can inspect state with:

    terraform state list

Example output:

    aws_instance.example

------------------------------------------------------------------------

# 10. Terraform Import Limitations

Important limitations:

### 10.1 Does Not Generate Configuration

Terraform only imports **state**, not `.tf` code.

You must manually write configuration.

------------------------------------------------------------------------

### 10.2 Resource IDs Are Provider Specific

Each provider defines its own import ID format.

Examples:

  Resource   Import ID
  ---------- -------------
  EC2        instance ID
  S3         bucket name
  VPC        vpc-id

Always check provider documentation.

------------------------------------------------------------------------

### 10.3 Complex Resources

Some resources require **compound IDs**.

Example:

    terraform import aws_route53_record.example ZONEID_RECORDNAME_TYPE

------------------------------------------------------------------------

# 11. Terraform Import Best Practices

## 11.1 Import Small Groups

Import resources gradually instead of everything at once.

------------------------------------------------------------------------

## 11.2 Validate After Import

Always run:

    terraform plan

------------------------------------------------------------------------

## 11.3 Match Configuration Exactly

Ensure `.tf` matches the real resource configuration.

------------------------------------------------------------------------

## 11.4 Backup Terraform State

Before importing:

    cp terraform.tfstate terraform.tfstate.backup

------------------------------------------------------------------------

# 12. Advanced Terraform Import

## Import Multiple Resources

Example script:

    terraform import aws_instance.web1 i-123
    terraform import aws_instance.web2 i-456
    terraform import aws_instance.web3 i-789

------------------------------------------------------------------------

## Terraform State Commands

Useful commands:

    terraform state list
    terraform state show
    terraform state mv
    terraform state rm

Example:

    terraform state show aws_instance.example

------------------------------------------------------------------------

# 13. Terraform Import with Terraform 1.5+

Terraform 1.5 introduced **configuration-driven import blocks**.

Example:

    import {
      to = aws_instance.example
      id = "i-123456"
    }

Then run:

    terraform plan

Terraform will automatically import the resource.

Advantages:

-   Version controlled
-   Works in CI/CD pipelines
-   Safer automation

------------------------------------------------------------------------

# 14. Real DevOps Example

Scenario:

Company has:

-   50 EC2 instances
-   10 RDS databases
-   20 S3 buckets

Created manually in AWS.

Migration plan:

    1. Write Terraform modules
    2. Import infrastructure
    3. Validate with terraform plan
    4. Move to Terraform-managed infrastructure

Benefits:

-   Infrastructure as Code
-   Version control
-   Automation
-   Safer deployments

------------------------------------------------------------------------

# 15. Terraform Import vs Terraform Apply

  Feature                      Import      Apply
  ---------------------------- ----------- ------------
  Creates infrastructure       No          Yes
  Adds resource to state       Yes         Yes
  Requires existing resource   Yes         No
  Use case                     Migration   Deployment

------------------------------------------------------------------------

# 16. Summary

Terraform Import is essential when adopting Terraform in existing environments.

Key points:

-   Imports existing resources into Terraform state
-   Requires manual configuration
-   Useful for infrastructure migration
-   Must validate with `terraform plan`

Best practice:

Use Terraform Import carefully and validate infrastructure state after every import.

------------------------------------------------------------------------
