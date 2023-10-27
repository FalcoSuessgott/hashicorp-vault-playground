terraform {
  required_version = ">= 1.6.0"

  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
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

# tflint-ignore: terraform_unused_declarations
data "http" "request" {
  url = var.url

  insecure    = var.insecure
  ca_cert_pem = var.ca_cert

  request_headers = {
    Accept = "application/json"
  }

  retry {
    attempts = 3
  }
}
