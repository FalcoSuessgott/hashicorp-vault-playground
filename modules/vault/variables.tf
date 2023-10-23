variable "vault_nodes" {
  type = number
}

variable "ip_subnet" {
  type = string
}

variable "base_port" {
  type    = number
  default = "8000"
}

variable "initialization" {
  type = object({
    shares    = number
    threshold = number
  })
}

variable "vault_version" {
  type = string
}

variable "ca_cert_file" {
  type    = string
  default = "./vault/ca.crt"
}

variable "key_file" {
  type    = string
  default = "./vault/vault.key"
}

variable "cert_file" {
  type    = string
  default = "./vault/vault.crt"
}

# variable "haproxy_port" {
#   type    = number
#   default = 443
# }
