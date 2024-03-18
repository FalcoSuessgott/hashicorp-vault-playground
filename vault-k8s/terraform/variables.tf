variable "service_account_name" {
  type    = string
  default = "sa-validator"
}

variable "ca_cert" {
  type = string
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "kms_enabled" {
  type = bool
}
