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
  pm_api_token_id = var.pm_user
  pm_tls_insecure = true
  pm_log_enable   = true
  pm_log_file     = "terraform-plugin-proxmox.log"
  pm_debug        = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

resource "proxmox_vm_qemu" "deploy_k8s_masters" {
  count              = var.vm_master_count
  name               = "k8s-master-node${01 + count.index}"
  target_node        = var.target_node
  vmid               = 1021 + count.index
  bios               = "ovmf"
  start_at_node_boot = false
  vm_state           = "stopped"
  agent              = 1
  boot               = "order=scsi0;net0"
  clone              = "debian12-cloudinit"
  memory             = "4096"
  balloon            = 0
  scsihw             = "virtio-scsi-single"
  tags               = "k8s,master"

  cpu {
    cores   = 2
    sockets = 2
    type    = "host"
  }

  network {
    id      = 0
    model   = "virtio"
    #macaddr = "08:08:08:08:08:0${count.index}"
    bridge  = "vmbr0"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          backup   = false
          cache    = "writeback"
          discard  = true
          iothread = true
          size     = "16G"
          storage  = var.scsi_1_name
        }
      }

      scsi1 {
        disk {
          backup   = false
          cache    = "writeback"
          discard  = true
          iothread = true
          size     = "5G"
          storage  = var.scsi_2_name
        }
      }
    }
  
      ide {
        ide1 {
          cloudinit {
            storage = "local-lvm"
          }
        }
      }
    }


  efidisk {
    efitype = "4m"
    storage = "local-lvm"
  }

  serial {
    id   = 0
    type = "socket"
  }

  # Cloud-Init configuration
  cicustom   = "vendor=local:snippets/qemu-guest-agent.yml"
  ciupgrade  = true
  nameserver = "1.1.1.1 8.8.8.8"
  ipconfig0  = "ip=192.168.1.${121 + count.index}/24,gw=192.168.1.254"
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

resource "proxmox_vm_qemu" "deploy_k8s_workers" {
  count              = var.vm_worker_count
  name               = "k8s-worker-node${01 + count.index}"
  target_node        = var.target_node
  vmid               = 1031 + count.index
  bios               = "ovmf"
  start_at_node_boot = false
  vm_state           = "stopped"
  agent              = 1
  boot               = "order=scsi0;net0"
  clone              = "debian12-cloudinit"
  memory             = "4096"
  balloon            = 0
  scsihw             = "virtio-scsi-single"
  tags               = "k8s,worker"

  cpu {
    cores   = 2
    sockets = 2
    type    = "host"
  }

  network {
    id      = 0
    model   = "virtio"
    #macaddr = "12:34:56:78:90:0${count.index}"
    bridge  = "vmbr0"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          backup   = false
          cache    = "writeback"
          discard  = true
          iothread = true
          size     = "16G"
          storage  = var.scsi_1_name
        }
      }

      scsi1 {
        disk {
          backup   = false
          cache    = "writeback"
          discard  = true
          iothread = true
          size     = "5G"
          storage  = var.scsi_2_name
        }
      }
    }

    ide {
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }


  efidisk {
    efitype = "4m"
    storage = "local-lvm"
  }

  serial {
    id   = 0
    type = "socket"
  }

  # Cloud-Init configuration
  cicustom   = "vendor=local:snippets/qemu-guest-agent.yml"
  ciupgrade  = true
  nameserver = "1.1.1.1 8.8.8.8"
  ipconfig0  = "ip=192.168.1.${131 + count.index}/24,gw=192.168.1.254"
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
