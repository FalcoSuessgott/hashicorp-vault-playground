variable "dns_sans" {
  type = list(string)
}

variable "ip_sans" {
  type = list(string)
}

variable "ca_cn" {
  type = string
}

variable "cert_cn" {
  type = string
}
