# HashiCorp Configuration Language (HCL)

## HCL Core: Anatomy of the 7 Pillars of Terraform

Welcome back to **Tony Tech Lab**. Based on official documentation and hands-on experience, this article accurately summarizes the **7 core components of HCL (HashiCorp Configuration Language)** to help you master **Infrastructure as Code (IaC)**.

---

## 1. Comments

HCL supports **three types of comments**, but you should know which one is considered the *standard*:

- `#`  
  **Standard and recommended.**  
  This is Terraform’s default comment style. Use it for all comments.

- `//`  
  Similar to C/Java. Works, but **not recommended**.

- `/* ... */`  
  Block comment. Useful for disabling large sections of code.

---

## 2. Blocks & Anatomy

An HCL block always follows this structure:

**Type → Label(s) → Body**

```hcl
resource "aws_instance" "web" {
  # Body (Attributes)
  ami           = "ami-123xyz"
  instance_type = "t3.micro"
}
```

---

## 3. Data Types: The “Critical” Differences

Besides `string`, `number`, and `bool`, you must clearly understand complex data types:

- **List `[ ... ]`**  
  Ordered collection.  
  Used for command lists, security rules, etc.

- **Set**  
  Unordered and unique values.  
  Used for IDs, IAM users, unique resources.

- **Object**  
  The most powerful hybrid type (can contain strings, numbers, booleans, and more).

---

## 4. Conditionals

The ternary operator makes your configuration **dynamic**:

```hcl
instance_type = var.env == "prod" ? "t3.large" : "t3.micro"
```

---

## 5. Functions & Terraform Console

Terraform provides dozens of built-in functions such as:

- `format()`
- `timestamp()`
- `jsonencode()`

👉 Use **`terraform console`** to quickly test functions before putting them into production code.

---

## 6. Dependencies

Understanding how Terraform builds its **dependency graph** is critical:

- **Implicit Dependency (Recommended)**  
  ```hcl
  vpc_id = aws_vpc.main.id
  ```

- **Explicit Dependency (Use only when necessary)**  
  ```hcl
  depends_on = [aws_vpc.main]
  ```

⚠️ Explicit dependencies reduce parallelism and can slow down execution.

---

## 7. Modules (Distribute Configuration)

This is the **final and most important piece** for understanding **code distribution**.

Modules allow you to **package and distribute infrastructure code** efficiently.

### 📦 Packaging Mindset

Instead of copy-pasting VPC code across 10 projects, you:

- Write **one standardized VPC module**
- Reuse it across **Dev, Staging, and Prod**
- Apply different inputs per environment

This is how HCL implements the **DRY principle (Don’t Repeat Yourself)**.

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

Mastering these **7 pillars** will give you a solid foundation to build reliable, maintainable Terraform infrastructure.
