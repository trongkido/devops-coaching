provider "proxmox" {
  endpoint = "https://192.168.88.210:8006"
  # Token User
  api_token = "<user_name>!<api_token_id>=<api_token>"
  insecure  = true
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = "trongnv-lab"
  node_name = "pve"

  # --- [REQUIREMENT: AUTO START] ---
  # Tự động bật máy ngay sau khi tạo xong
  started = true

  clone {
    vm_id = 100
    full  = true
    # [Mẹo nhỏ] Tăng thời gian chờ clone nếu disk lớn
    # retries = 3 
  }

  cpu {
    cores = 1
    # [Tối ưu] Đặt loại CPU là 'host' để hiệu năng tốt nhất (nếu không cần migrate sang CPU khác đời)
    type = "host"
  }

  memory {
    dedicated = 1024
  }

  network_device {
    bridge = "vmbr0"
  }

  # Tắt QEMU Agent để tránh lỗi chờ đợi nếu image chưa cài agent
  agent {
    enabled = false
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    # [Tùy chọn] Set user/pass mặc định nếu Cloud-Init hỗ trợ
    # user_account {
    #   username = "student"
    #   password = "password123"
    # }
  }
}
