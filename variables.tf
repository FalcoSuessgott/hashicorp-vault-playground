variable "vault" {
  type = object({
    ip_subnet = optional(string, "172.16.10.0/24")
    version   = optional(string, "1.15")
    base_port = optional(number, 8000)
    nodes     = optional(number, 3)
    initialization = optional(object({
      shares    = number
      threshold = number
      }), {
      shares    = 5
      threshold = 3
    })
  })
}

variable "boundary" {
  type = object({
    enabled = optional(bool, false)
  })
}

variable "databases" {
  type = object({
    enabled = optional(bool, true)
    mysql   = optional(bool, true)
  })
}

variable "kubernetes" {
  type = object({
    enabled                  = optional(bool, true)
    kms                      = optional(bool, false)
    external_secrets_manager = optional(bool, true)
    vault_secrets_operator   = optional(bool, true)
    vault_agent_injector     = optional(bool, true)
    csi                      = optional(bool, true)
    cert_manager             = optional(bool, true)
  })
}
