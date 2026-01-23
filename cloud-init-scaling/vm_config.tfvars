vm_config = [
  {
    vmid       = "1000"
    name       = "controller-vm-01"
    cores      = 2
    memory     = 2048
    disk_gb    = 20
    ip_address = "192.168.1.100/24"
    template   = "debian12-cloudinit"
    storage    = "local-lvm"
    tags       = "controller"
  },
  {
    vmid       = "1001"
    name       = "app-vm-01"
    cores      = 2
    memory     = 2048
    disk_gb    = 20
    ip_address = "192.168.1.101/24"
    template   = "debian12-cloudinit"
    storage    = "local-lvm"
    tags       = "apps"
  },
  {
    vmid       = "1002"
    name       = "app-vm-02"
    cores      = 2
    memory     = 2048
    disk_gb    = 20
    ip_address = "192.168.1.102/24"
    template   = "debian12-cloudinit"
    storage    = "local-lvm"
    tags       = "apps"
  },
  {
    vmid       = "1003"
    name       = "app-vm-03"
    cores      = 4
    memory     = 4096
    disk_gb    = 20
    ip_address = "192.168.1.103/24"
    template   = "debian12-cloudinit"
    storage    = "local-lvm"
    tags       = "apps"
  },
  {
    vmid       = "1011"
    name       = "db-vm-01"
    cores      = 2
    memory     = 2048
    disk_gb    = 20
    ip_address = "192.168.1.111/24"
    template   = "debian12-cloudinit"
    storage    = "local-lvm"
    tags       = "database"
  },
  {
    vmid       = "1012"
    name       = "db-vm-02"
    cores      = 2
    memory     = 2048
    disk_gb    = 20
    ip_address = "192.168.1.112/24"
    template   = "debian12-cloudinit"
    storage    = "local-lvm"
    tags       = "database"
  }
]
