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
