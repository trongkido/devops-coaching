
# Terraform Testing – Complete Guide

## 1. What is Terraform Testing?
Terraform Testing is the practice of validating Terraform configurations to ensure infrastructure behaves as expected before deployment.

Testing helps DevOps engineers:
- Detect configuration errors early
- Validate infrastructure behavior
- Prevent production failures
- Maintain reliable Infrastructure as Code (IaC)

Terraform supports several types of testing approaches:
1. Static validation
2. Built-in Terraform tests (`terraform test`)
3. Policy testing
4. Integration testing
5. External testing frameworks

---

## 2. Why Terraform Testing is Important

| Benefit | Description |
|--------|-------------|
| Prevent infrastructure errors | Catch issues before deployment |
| Improve reliability | Validate infrastructure behavior |
| Support CI/CD pipelines | Automated infrastructure checks |
| Documentation | Tests describe expected infrastructure |
| Safer refactoring | Ensure changes don't break infrastructure |

---

## 3. Types of Terraform Testing

### 3.1 Syntax Validation
Command:
```
terraform validate
```

Purpose:
- Validate Terraform syntax
- Detect missing variables
- Check provider configuration

---

### 3.2 Terraform Plan Testing
Command:
```
terraform plan
```

Use cases:
- Verify resource creation
- Detect unintended changes
- Prevent destructive operations

---

### 3.3 Native Terraform Tests

Terraform provides a built‑in testing framework:

```
terraform test
```

Tests are written in `.tftest.hcl` files.

Example structure:

```
project/
 ├── main.tf
 ├── variables.tf
 └── tests/
      └── example.tftest.hcl
```

---

## 4. Terraform Test Command

```
terraform test
```

This command:
- Executes test files
- Creates temporary infrastructure
- Validates expected results
- Automatically destroys test resources

---

## 5. Terraform Test File Structure

Example:

```
run "example_test" {
  command = plan
}
```

---

## 6. Example Terraform Test

Terraform resource:

```
resource "aws_s3_bucket" "example" {
  bucket = "my-test-bucket-123"
}
```

Test file:

```
run "s3_bucket_test" {

  command = plan

  assert {
    condition     = aws_s3_bucket.example.bucket != ""
    error_message = "Bucket name should not be empty"
  }

}
```

---

## 7. Test Commands

| Command | Description |
|-------|-------------|
| plan | Run terraform plan |
| apply | Run terraform apply |
| destroy | Run terraform destroy |

---

## 8. Assertions

Example:

```
assert {
  condition     = aws_instance.web.instance_type == "t3.micro"
  error_message = "Instance type must be t3.micro"
}
```

---

## 9. Test Variables

```
variables {
  instance_type = "t3.micro"
}
```

---

## 10. Mock Providers

Terraform tests support **mock providers** to simulate infrastructure.

Example concept:

```
mock_provider "aws" {}
```

Benefits:
- Faster tests
- No real cloud resources needed
- Safe testing environment

---

## 11. Integration Testing with Terratest

Terratest is a Go-based testing framework.

Workflow:
1. Deploy infrastructure with Terraform
2. Validate infrastructure using Go tests
3. Destroy infrastructure

---

## 12. Policy Testing

Organizations enforce policies using:
- HashiCorp Sentinel
- Open Policy Agent (OPA)

Examples:
- Require encryption
- Require tags
- Restrict instance types

---

## 13. Terraform Testing in CI/CD

Typical CI pipeline:

```
terraform fmt -check
terraform validate
terraform plan
terraform test
```

---

## 14. Best Practices

- Write tests for reusable modules
- Automate testing in CI/CD
- Test multiple configurations
- Keep tests isolated
- Ensure infrastructure cleanup

---

## 15. Example DevOps Workflow

```
Developer writes Terraform code
        ↓
terraform fmt
        ↓
terraform validate
        ↓
terraform plan
        ↓
terraform test
        ↓
CI/CD approval
        ↓
terraform apply
```

---

## 16. Summary

Terraform testing ensures infrastructure reliability.

Key tools:
- terraform validate
- terraform plan
- terraform test
- Terratest
- Sentinel / OPA

Benefits:
- Detect errors early
- Improve infrastructure reliability
- Enable safe Infrastructure as Code practices

---
