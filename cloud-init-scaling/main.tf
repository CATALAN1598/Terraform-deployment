terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.pm_url
  pm_tls_insecure = true
  pm_log_enable   = true
  pm_log_file     = "terraform-plugin-proxmox.log"
  pm_debug        = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

locals {
  vm_mapping = {
    for vm in var.vm_config : vm.name => vm
  }
}

resource "proxmox_vm_qemu" "cloudinit-lab-deployment" {
  for_each = local.vm_mapping

  automatic_reboot = false
  vmid             = each.value.vmid
  name             = each.value.name
  target_node      = var.target_node
  agent            = 0
  memory   = each.value.memory
  boot     = "order=scsi0"
  clone    = each.value.template
  scsihw   = "virtio-scsi-single"
  vm_state = "running"
  tags     = each.value.tags

  cpu {
    type  = "host"
    cores = each.value.cores
  }

  serial {
    id = 0
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage  = each.value.storage
          discard  = true
          cache    = "writeback"
          iothread = true
          size     = each.value.disk_gb
        }
      }
      #scsi1 {
      #  disk {
      #    storage = "local-lvm"
      #    discard = true
      #    cache = "writeback"
      #    iothread = true
      #    size = 10
      #  }
      #}
    }
    ide {
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Cloud-Init configuration
  cicustom   = "vendor=local:snippets/qemu-guest-agent.yml"
  ciupgrade  = true
  nameserver = "1.1.1.1 8.8.8.8"
  ipconfig0  = "ip=${each.value.ip_address},gw=192.168.1.1"
  skip_ipv6  = true
  ciuser     = "root"
  cipassword = "password"
  sshkeys    = <<-EOF
ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx terraform@domain.local
  EOF


  lifecycle {
    ignore_changes = [
      vmid,
      vm_state,
      network,
      ipconfig0,
      startup_shutdown,
      cipassword,
      cicustom
    ]
  }
}
