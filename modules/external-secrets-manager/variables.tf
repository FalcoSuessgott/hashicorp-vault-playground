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

variable "secret_store_name" {
  type    = string
  default = "secret-store"
}

variable "external_secret_name" {
  type    = string
  default = "external-secret"
}

variable "k8s_secret_name" {
  type    = string
  default = "esm-secret"
}
