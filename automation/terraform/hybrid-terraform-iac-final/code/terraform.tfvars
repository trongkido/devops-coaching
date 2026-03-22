# Proxmox Connection
proxmox_endpoint     = "https://192.168.88.210:8006"
proxmox_user_name    = "<user_name>@pve"
proxmox_api_token_id = "<user_name>"
proxmox_api_token    = "<user_api_token>"
proxmox_node         = "pve"
proxmox_ssh_user     = "<promox_ssh_user>"
proxmox_ssh_password = "<promox_ssh_password>"

# Template Configuration
template_name          = "rocky9-template"
vm_id                  = 101
snippet_datastore      = "local"
template_root_password = "<template_ssh_password>"
image_url              = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"

# VM Configuration
#template_vm_id = 101
db_vm_id     = 200
db_vm_name   = "db-server-01"
vm_memory    = 2048
vm_cores     = 1
db_disk_size = 8

# Network Configuration
db_ip_address = "192.168.88.100/24"
db_gateway    = "192.168.88.1"

# VM OS Configuration
vm_user     = "<vm_user>"
vm_password = "<vm_password>"

# Database Configuration
db_root_password = "<db_root_password>"
db_app_user      = "<db_app_user>"
db_app_password  = "<db_app_password>"
db_app_schema    = "snippetvault"

# Project Metadata
project_name = "hybrid-lab"
environment  = "dev"
