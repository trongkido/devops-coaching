resource "proxmox_virtual_environment_vm" "database" {
  name      = var.db_vm_name
  node_name = var.proxmox_node
  vm_id     = var.db_vm_id

  clone {
    vm_id   = var.template_vm_id
    full    = true
    retries = 1
  }

  cpu {
    cores = var.vm_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.db_disk_size
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  agent {
    enabled = true
  }

  ## Cloud-init configuration
  initialization {
    user_account {
      username = var.vm_user
      password = var.vm_password
      keys     = [var.ssh_key]
    }

    ip_config {
      ipv4 {
        address = var.db_ip_address
        gateway = var.db_gateway
      }
    }

    dns {
      servers = ["8.8.8.8", "1.1.1.1"]
    }
  }

  lifecycle {
    ignore_changes = [clone]
  }
}

# ==============================================================
# Provisioner: Wait for cloud-init to complete
# ==============================================================
resource "null_resource" "wait_for_cloudinit" {
  triggers = {
    vm_id = proxmox_virtual_environment_vm.database.id
  }

  connection {
    type        = "ssh"
    host        = split("/", var.db_ip_address)[0]
    user        = var.vm_user
    password    = var.vm_password
    private_key = var.ssh_private_key
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      # Wait for cloud-init to complete
      #"sudo cloud-init status --wait",
      #"echo 'Cloud-init done, VM is ready!'"
      "echo Waiting for cloud-init to finish...",
      "while pgrep -x cloud-init >/dev/null; do sleep 2; done",
      "echo Cloud-init finished"
    ]
  }

  depends_on = [proxmox_virtual_environment_vm.database]
}

# ==============================================================
# Provisioner: Install MySQL container
# ==============================================================
resource "null_resource" "install_mysql_container" {
  triggers = {
    vm_id = proxmox_virtual_environment_vm.database.id
  }

  connection {
    type        = "ssh"
    host        = split("/", var.db_ip_address)[0]
    user        = var.vm_user
    password    = var.vm_password
    private_key = var.ssh_private_key
    timeout     = "5m"
  }

  provisioner "file" {
     source      = "${path.module}/scripts/db_init.sh"
     destination = "/tmp/db_init.sh"
   }
 
   provisioner "file" {
     source      = "${path.module}/scripts/tables_init.sql"
     destination = "/tmp/tables_init.sql"
   }
 
   provisioner "remote-exec" {
     inline = [
       "chmod +x /tmp/db_init.sh",
   <<EOF
count=0
max_retries=3

until [ $count -ge $max_retries ]
do
  echo "Attempt $((count+1)) running db_init.sh..."

  bash -x /tmp/db_init.sh '${var.db_root_password}' '${var.db_app_schema}' '${var.db_app_user}' '${var.db_app_password}' && break

  count=$((count+1))
  echo "Failed. Retry in 10s..."
  sleep 10
done

if [ $count -eq $max_retries ]; then
  echo "db_init.sh failed after $max_retries attempts"
  exit 1
fi
EOF    
     ]
   }

  depends_on = [null_resource.wait_for_cloudinit]
}