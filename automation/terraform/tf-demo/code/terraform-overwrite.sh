#!/bin/bash

## Force resource recreation
terraform apply -replace="module.ec2_instance.aws_instance.example"

## Terraform plan output:
# -/+ aws_instance.example (replace)
## Meaning
# Destroy old instance
# Create new instance
