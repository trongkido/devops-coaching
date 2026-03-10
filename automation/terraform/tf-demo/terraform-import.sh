#!/bin/bash

## Import the existing EC2 instance
terraform import module.ec2_instance.aws_instance.example i-123456789

## Verify
terraform plan
