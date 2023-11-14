variable "service_account_name" {
  type    = string
  default = "sa-validator"
}


variable "namespace" {
  type    = string
  default = "default"
}

variable "kms_enabled" {
  type = bool
}
