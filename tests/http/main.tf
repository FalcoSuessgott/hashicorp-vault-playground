terraform {
  required_version = ">= 1.6.0"

  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }
  }
}

variable "url" {
  type = string
}

variable "ca_cert" {
  type    = string
  default = null
}

variable "insecure" {
  type    = bool
  default = true
}

variable "method" {
  type    = string
  default = "GET"
}

variable "header" {
  type    = map(string)
  default = null
}

# tflint-ignore: terraform_unused_declarations
data "http" "request" {
  url    = var.url
  method = var.method

  insecure    = var.insecure
  ca_cert_pem = var.ca_cert

  request_headers = merge(var.header, { Accept = "application/json" })

  retry {
    attempts = 3
  }
}
