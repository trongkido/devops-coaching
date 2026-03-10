# Terraform Logging -- Complete Guide

## 1. What is Terraform Logging?

Terraform Logging provides detailed information about Terraform's internal operations during execution. Logs help DevOps engineers debug issues, understand Terraform behavior, and troubleshoot provider errors.

Terraform logs can show: - API calls to cloud providers - Terraform dependency graph operations - Provider plugin communication - State file interactions - Errors and warnings

Terraform logging is mainly controlled through environment variables.

------------------------------------------------------------------------

# 2. Why Terraform Logging is Important

Terraform logs are useful for:

  Use Case                     Description
  ---------------------------- -----------------------------------
  Debugging Terraform errors   Identify why resources fail
  Provider troubleshooting     Understand API calls
  CI/CD debugging              Investigate pipeline failures
  Performance analysis         Identify slow operations
  Support cases                Provide logs to HashiCorp support

------------------------------------------------------------------------

# 3. Terraform Logging Levels

Terraform supports several log levels:

  Level   Description
  ------- --------------------------------
  TRACE   Most detailed logging
  DEBUG   Detailed debugging information
  INFO    General operational messages
  WARN    Warnings
  ERROR   Errors only
  OFF     Disable logging

Example:

    export TF_LOG=DEBUG

------------------------------------------------------------------------

# 4. Enabling Terraform Logs

Terraform logs are enabled using the **TF_LOG environment variable**.

Example:

    export TF_LOG=TRACE
    terraform apply

Terraform will output logs directly to the console.

------------------------------------------------------------------------

# 5. Writing Logs to a File

Terraform logs can be written to a file using **TF_LOG_PATH**.

Example:

    export TF_LOG=DEBUG
    export TF_LOG_PATH=terraform.log
    terraform apply

This will generate a log file named:

    terraform.log

------------------------------------------------------------------------

# 6. Example Debug Workflow

    export TF_LOG=DEBUG
    export TF_LOG_PATH=terraform-debug.log

    terraform init
    terraform plan
    terraform apply

Then inspect the log file:

    cat terraform-debug.log

------------------------------------------------------------------------

# 7. Terraform Provider Logging

Terraform providers also generate logs.

Examples:

-   AWS provider
-   Kubernetes provider
-   Azure provider
-   Google Cloud provider

Example log snippet:

    provider.aws: sending request to AWS API

------------------------------------------------------------------------

# 8. Terraform Plugin Logs

Terraform communicates with providers through plugin processes.

Logs may include:

-   Plugin startup messages
-   Plugin RPC communication
-   Provider API requests

Example:

    plugin: starting plugin

------------------------------------------------------------------------

# 9. Sensitive Data in Logs

Important: Terraform logs may contain sensitive information such as:

-   API keys
-   Tokens
-   Secrets
-   Credentials

Best practices:

-   Never commit logs to Git
-   Secure log storage
-   Delete logs after debugging

------------------------------------------------------------------------

# 10. Disabling Terraform Logs

Disable logging with:

    unset TF_LOG

or

    export TF_LOG=OFF

------------------------------------------------------------------------

# 11. Terraform Logging in CI/CD

Example GitHub Actions configuration:

    env:
      TF_LOG: DEBUG
      TF_LOG_PATH: terraform-ci.log

Logs can be stored as CI artifacts.

------------------------------------------------------------------------

# 12. Common Terraform Log Messages

Examples:

Provider initialization:

    provider.aws: initializing

API request:

    provider.aws: sending request to AWS EC2 API

Dependency graph building:

    terraform: building dependency graph

Resource creation:

    aws_instance.example: Creating...

------------------------------------------------------------------------

# 13. Best Practices

### Enable logs only when debugging

TRACE logs generate large files.

### Secure log files

Logs may contain sensitive information.

### Use logs for troubleshooting

Enable DEBUG logs when investigating Terraform failures.

### Clean logs after debugging

------------------------------------------------------------------------

# 14. DevOps Troubleshooting Example

Problem: Terraform fails to create AWS resources.

Solution:

    export TF_LOG=DEBUG
    export TF_LOG_PATH=terraform-debug.log
    terraform apply

Then review the log file for issues such as IAM permission errors.

Example error:

    AccessDenied: User is not authorized to perform ec2:RunInstances

------------------------------------------------------------------------

# 15. Terraform Logging vs Cloud Provider Logging

  Feature   Terraform Logs          Cloud Provider Logs
  --------- ----------------------- -------------------------
  Scope     Terraform execution     Infrastructure activity
  Example   terraform apply debug   AWS CloudTrail
  Purpose   Debug IaC               Audit infrastructure

------------------------------------------------------------------------

# 16. Summary

Terraform logging is essential for debugging Infrastructure as Code.

Key points:

-   Enable logs using **TF_LOG**
-   Save logs with **TF_LOG_PATH**
-   Use DEBUG or TRACE levels for troubleshooting
-   Protect sensitive information in logs

------------------------------------------------------------------------
