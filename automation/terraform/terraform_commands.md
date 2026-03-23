# Terraform Commands Cheat Sheet (With Explanations)

## 1. Initialization

### `terraform init`

Initialize a Terraform working directory. - Downloads providers - Sets
up backend - Prepares modules

------------------------------------------------------------------------

## 2. Formatting & Validation

### `terraform fmt`

Formats Terraform files to standard style.

### `terraform validate`

Validates syntax and configuration.

------------------------------------------------------------------------

## 3. Planning & Applying

### `terraform plan`

Shows execution plan (what will change).

### `terraform apply`

Applies changes to infrastructure.

### `terraform apply -auto-approve`

Apply without manual approval.

------------------------------------------------------------------------

## 4. Destroy Infrastructure

### `terraform destroy`

Deletes all managed resources.

------------------------------------------------------------------------

## 5. State Management

### `terraform state list`

List resources in state.

### `terraform state show <resource>`

Show details of a resource.

### `terraform state rm <resource>`

Remove resource from state.

### `terraform state mv <src> <dest>`

Move resource in state.

------------------------------------------------------------------------

## 6. Output & Variables

### `terraform output`

Show output variables.

### `terraform console`

Interactive console for testing expressions.

------------------------------------------------------------------------

## 7. Workspace Management

### `terraform workspace list`

List workspaces.

### `terraform workspace new <name>`

Create new workspace.

### `terraform workspace select <name>`

Switch workspace.

### `terraform workspace delete <name>`

Delete workspace.

------------------------------------------------------------------------

## 8. Providers & Dependencies

### `terraform providers`

Show required providers.

### `terraform providers lock`

Lock provider versions.

------------------------------------------------------------------------

## 9. Import Existing Resources

### `terraform import <resource> <id>`

Import existing infrastructure.

------------------------------------------------------------------------

## 10. Graph & Debugging

### `terraform graph`

Visualize dependency graph.

### `terraform taint <resource>`

Force resource recreation.

### `terraform untaint <resource>`

Remove taint.

------------------------------------------------------------------------

## 11. Advanced Commands

### `terraform refresh`

Update state with real infrastructure.

### `terraform login`

Authenticate with Terraform Cloud.

### `terraform logout`

Remove credentials.

------------------------------------------------------------------------

## 12. Backend & State Pull/Push

### `terraform state pull`

Download current state.

### `terraform state push`

Upload modified state.

------------------------------------------------------------------------

## Notes

-   Always run `terraform init` first
-   Use `plan` before `apply`
-   Avoid manual state edits unless necessary
