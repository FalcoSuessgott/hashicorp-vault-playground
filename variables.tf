variable "vault" {
  type = object({
    ip_subnet          = optional(string, "172.16.10.0/24")
    vault_enterprise   = optional(bool, false)
    vault_version      = optional(string, "latest")
    vault_nodes        = optional(number, 3)
    autounseal_enabled = optional(bool, false)
    keys = optional(object({
      shares    = number
      threshold = number
      }), {
      shares    = 5
      threshold = 3
    })
  })

  default = null
}

variable "haproxy" {
  type = object({
    enabled = optional(bool, true)
  })
}

variable "grafana" {
  type = object({
    enabled = optional(bool, true)
    port    = optional(number, 3000)
  })
}

variable "prometheus" {
  type = object({
    enabled = optional(bool, true)
    port    = optional(number, 9090)
  })
}
