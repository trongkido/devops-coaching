# Terraform Provisioners -- Complete Guide

## 1. What is a Terraform Provisioner?

A **Terraform Provisioner** is a feature that allows you to execute scripts or commands on a **local machine or a remote resource** as part of the Terraform resource lifecycle.

Provisioners are typically used to:

-   Bootstrap servers
-   Install software
-   Run configuration scripts
-   Execute automation tasks after resource creation

However, Terraform documentation recommends using provisioners **only as a last resort**, because configuration management tools (Ansible, Chef, Puppet, etc.) are usually better suited for these tasks.

------------------------------------------------------------------------

# 2. When Terraform Provisioners Run

Provisioners can run at two lifecycle stages:

  Stage           Description
  --------------- ---------------------------------------
  Creation-time   Runs after the resource is created
  Destroy-time    Runs before the resource is destroyed

Example:

``` hcl
provisioner "local-exec" {
  command = "echo Instance created"
}
```

------------------------------------------------------------------------

# 3. Types of Terraform Provisioners

Terraform supports several built-in provisioners.

## 3.1 local-exec Provisioner

Runs a command on the **machine running Terraform**.

Example:

``` hcl
resource "null_resource" "example" {

  provisioner "local-exec" {
    command = "echo Hello from Terraform"
  }

}
```

Use cases:

-   Trigger scripts
-   Send notifications
-   Call APIs
-   Generate configuration files

------------------------------------------------------------------------

## 3.2 remote-exec Provisioner

Runs commands on a **remote machine** (usually via SSH or WinRM).

Example:

``` hcl
resource "aws_instance" "web" {

  ami           = "ami-123456"
  instance_type = "t2.micro"

  provisioner "remote-exec" {

    inline = [
      "sudo yum update -y",
      "sudo yum install nginx -y"
    ]

  }

}
```

------------------------------------------------------------------------

## 3.3 file Provisioner

Copies files from local machine to remote machine.

Example:

``` hcl
provisioner "file" {
  source      = "app.conf"
  destination = "/etc/app/app.conf"
}
```

Use cases:

-   Upload configuration files
-   Deploy scripts
-   Copy application artifacts

------------------------------------------------------------------------

# 4. Connection Block

For remote provisioners, Terraform must know how to connect to the
resource.

Example:

``` hcl
connection {
  type        = "ssh"
  user        = "ec2-user"
  private_key = file("~/.ssh/id_rsa")
  host        = self.public_ip
}
```

Connection parameters:

  Parameter     Description
  ------------- -------------------------
  type          ssh or winrm
  user          remote username
  password      authentication password
  private_key   SSH private key
  host          remote host address

------------------------------------------------------------------------

# 5. Full Example with Provisioner

Example: Create an EC2 instance and install Nginx.

``` hcl
resource "aws_instance" "web" {

  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install nginx -y",
      "sudo systemctl start nginx"
    ]
  }

}
```

------------------------------------------------------------------------

# 6. Multiple Provisioners

You can define multiple provisioners in a single resource.

Example:

``` hcl
resource "aws_instance" "example" {

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh"
    ]
  }

}
```

------------------------------------------------------------------------

# 7. Destroy-Time Provisioners

Runs before resource destruction.

Example:

``` hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo Resource destroyed"
}
```

Use cases:

-   Deregister node
-   Cleanup resources
-   Backup data

------------------------------------------------------------------------

# 8. Provisioner Error Handling

Terraform stops execution if provisioner fails.

You can override this behavior:

``` hcl
provisioner "local-exec" {
  command     = "exit 1"
  on_failure  = continue
}
```

Options:

  Value      Behavior
  ---------- ---------------------------------
  fail       Default behavior
  continue   Continue even if failure occurs

------------------------------------------------------------------------

# 9. Best Practices for Terraform Provisioners

## 9.1 Avoid Provisioners When Possible

HashiCorp recommends using:

-   Cloud-init
-   Configuration management tools
-   Container images

Instead of provisioners.

------------------------------------------------------------------------

## 9.2 Keep Provisioners Simple

Provisioners should only perform lightweight tasks.

------------------------------------------------------------------------

## 9.3 Use Immutable Infrastructure

Instead of installing software via provisioners, build:

-   Pre-configured machine images
-   Docker containers

------------------------------------------------------------------------

## 9.4 Use Configuration Tools

Better alternatives:

  Tool         Purpose
  ------------ --------------------------
  Ansible      Configuration management
  Packer       Build machine images
  Kubernetes   Container orchestration

------------------------------------------------------------------------

# 10. Terraform Provisioner vs Configuration Management

  Feature      Terraform Provisioner   Configuration Tool
  ------------ ----------------------- --------------------
  Purpose      Bootstrap               Full configuration
  Complexity   Simple tasks            Complex automation
  Best Use     Small scripts           Server management

------------------------------------------------------------------------

# 11. Real DevOps Workflow

Typical infrastructure pipeline:

    Terraform → Create Infrastructure
            ↓
    Cloud-init / Packer → OS Configuration
            ↓
    Ansible → Application Setup
            ↓
    Kubernetes → Container Deployment

Provisioners should only be used when other options are unavailable.

------------------------------------------------------------------------

# 12. Summary

Terraform Provisioners allow execution of scripts during infrastructure
lifecycle.

Key points:

-   Used to run scripts after resource creation
-   Support local and remote execution
-   Can copy files to servers
-   Should be used **sparingly**

Most modern DevOps workflows prefer:

-   Cloud-init
-   Packer images
-   Configuration management tools

instead of heavy use of provisioners.

------------------------------------------------------------------------
