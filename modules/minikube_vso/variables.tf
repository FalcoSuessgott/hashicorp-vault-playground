variable "secrets" {
  type = map(string)
  default = {
    username = "Admin"
    password = "P@ssw0rd"
  }
}

variable "ca_cert" {
  type = string
}
