variable "target_node" {
  type = string
}

variable "pm_url" {
  type = string
}

variable "vm_config" {
  description = "VM configuration list"
  type = list(object({
    vmid       = number
    name       = string
    cores      = number
    memory     = number
    disk_gb    = number
    ip_address = string
    template   = string
    storage    = string
    tags       = string
  }))
}