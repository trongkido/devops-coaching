# HashiCorp Configuration Language (HCL)

## What is HCL?

HCL is a configuration language developed by HashiCorp with the goal of balancing two key factors:  
- **Easy for humans to read and understand**  
- **Easy for machines to process** (fully JSON-compatible)

HCL is **not only used in Terraform** — it is the **common language** across the entire leading HashiCorp DevOps ecosystem:

- **Terraform** (`.tf`)  
  → Used to define and provision infrastructure (Infrastructure as Code)

- **Packer** (`.pkr.hcl`)  
  → Used to build machine images (AMI, Docker images, etc.)

- **Nomad** (`.nomad`)  
  → A simple yet powerful cluster scheduler (alternative to Kubernetes)

- **Consul** (`.hcl`)  
  → Service discovery, service mesh, and network configuration

- **Vault** (`.hcl`)  
  → Secrets management, encryption, identity, and secure storage

💡 **DevOps Perspective**:  
If you consider **YAML** as the language you use to talk to the Kubernetes API, then **HCL** is the language you use to communicate with the APIs of AWS, Azure, Google Cloud (and many others) through Terraform.

## HCL Core: Overview of the 7 Core Building Blocks

To truly master HCL, you need to deeply understand these **7 fundamental concepts**.  
Think of them as the **Lego pieces** you will use to build your infrastructure house:

1. **Comments** (Annotations)  
   → The way to leave notes and explain your code

2. **Blocks** (Blocks)  
   → The largest structural units that contain content

3. **Attributes** (Properties)  
   → Key = Value pairs that describe detailed settings

4. **Data Types** (Data Types)  
   → Formats of values (string, number, list, map, bool…)

5. **Conditionals** (Conditional Expressions)  
   → “If… then…” logic

6. **Functions** (Built-in Functions)  
   → Ready-to-use tools for transforming and processing data

7. **Resource Dependencies** (Dependencies)  
   → The order in which resources should be created/destroyed

## Detailed Breakdown of Each Component

### 1. Comments

HCL supports **three types of comments**, but you should know which one is considered the *standard*:

- `#`  
  **Standard and recommended.**  
  This is Terraform’s default comment style. Use it for all comments.

- `//`  
  Similar to C/Java. Works, but **not recommended**.

- `/* ... */`  
  Block comment. Useful for disabling large sections of code.

**Examples**:
```hcl
# This is a single-line comment (recommended style)

# Another common style
// This is also a single-line comment

/*
  This is a
  multi-line comment
  spanning several lines
*/
```

### 2. Blocks & Anatomy

An HCL block always follows this structure:

Syntax:
  **Type → Label(s) → Body**
```hcl
block_type "label_1" "label_2" {
  # Configuration content goes here
}
```

Real-world example:
```hcl
resource "aws_instance" "web" {
  # Body (Attributes)
  ami           = "ami-123xyz"
  instance_type = "t3.micro"
}
```

### 3. Attributes (Properties)

Attributes are the key = value pairs defined inside a block.

**Examples:**
```hcl
key1      = "value1"
port      = 8080
tags      = { Name = "WebServer" }
```

Important distinction:
- Arguments: Values you provide as input (what you set).
- Exported Attributes: Values returned by the provider after creation (output, e.g., public IP, ARN, ID).

### 4. Data Types: The “Critical” Differences

Besides `string`, `number`, and `bool`, you must clearly understand complex data types:

- **List `[ ... ]`**  
  Ordered collection.  
  Used for command lists, security rules, etc.

- **Set**  
  Unordered and unique values.  
  Used for IDs, IAM users, unique resources.

- **Object**  
  The most powerful hybrid type (can contain strings, numbers, booleans, and more).

Misunderstanding data types is one of the most common sources of errors when writing Terraform modules.

**Primitive Types**
- string: "Hello World", "ap-southeast-1"
- number: 15, 3.14
- bool: true, false

**Collection Types**
- list   : Ordered list of values ["a", "b", "c"] or [8080, 443]
- map    : Key-value pairs { "Environment" = "Dev", "Project" = "WebApp" }
- set    : Unordered collection of unique values (commonly used for IDs)

Examples:
```hcl
tags = {
  Name        = "web-server-01"
  Environment = "prod"
}

ports = [80, 443, 8080]
unique_ids = toset(["id-123", "id-456"])
```

### 5. Conditionals (Ternary Operator)

HCL uses the ternary operator instead of traditional if-else statements.

Syntax:
```hcl
condition ? value_if_true : value_if_false
```

The ternary operator makes your configuration **dynamic**:

Example:
```hcl
instance_type = var.env == "prod" ? "t3.large" : "t3.micro"
```

### 6. Functions (Built-in Functions)
HCL provides a rich library of built-in functions for data manipulation.
User-defined functions are not supported.

Terraform provides dozens of built-in functions such as:

- `format()`
- `timestamp()`
- `jsonencode()`

Common categories & examples:
- String: join, split, upper, lower, trimspace
- Numeric: min, max, ceil, floor
- Collection: length, element, index, keys, values, toset, tomap
- Filesystem: file("user-data.sh") — very useful for injecting scripts
- Type conversion: tobool, tonumber, tostring, try()
- Encoding: base64encode, jsonencode, yamlencode

Examples:
```hcl
name = upper("web-server")          # → "WEB-SERVER"
tags = join(",", ["dev", "team-a"]) # → "dev,team-a"
```

👉 Use **`terraform console`** to quickly test functions before putting them into production code.

### 7. Resource Dependencies

Understanding how Terraform builds its **dependency graph** is critical.
Terraform automatically builds a dependency graph to determine the correct order of resource creation and destruction.

**Two Types of Dependencies**
- **Implicit Dependency (Recommended)**
  Created automatically when one resource references an attribute of another.
  ```hcl
  resource "aws_instance" "web" {
    ami           = "ami-12345678"
    instance_type = "t2.micro"
  }

  resource "aws_eip" "web_eip" {
    instance = aws_instance.web.id   # ← Implicit dependency
  }
  ```
→ Terraform knows aws_instance.web must be created before aws_eip.web_eip.

- **Explicit Dependency (Use only when necessary)**  
  Use depends_on when there is no direct attribute reference but order is logically required.
  ```hcl
  resource "aws_db_instance" "main" {
    # ...
  }

  resource "null_resource" "db_migration" {
    depends_on = [aws_db_instance.main]   # ← Explicit dependency

    provisioner "local-exec" {
      command = "python migrate_db.py"
    }
  }
  ```

⚠️ Explicit dependencies reduce parallelism and can slow down execution.

---

## Modules (Distribute Configuration)

This is the **final and most important piece** for understanding **code distribution**.

Modules allow you to **package and distribute infrastructure code** efficiently.

### 📦 Packaging Mindset

Instead of copy-pasting VPC code across 10 projects, you:

- Write **one standardized VPC module**
- Reuse it across **Dev, Staging, and Prod**
- Apply different inputs per environment

This is how HCL implements the **DRY principle (Don’t Repeat Yourself)**.

Examples:
```hcl
module "vpc_distribution" {
  # Distribute code from a shared source
  source = "./modules/aws-vpc"

  # Environment-specific variables
  cidr_range = "10.0.0.0/16"
}
```

---

## ✅ Summary

HCL is designed to be:
- Human-readable
- Declarative
- Modular
- Scalable
