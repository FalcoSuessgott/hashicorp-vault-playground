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

# tflint-ignore: terraform_unused_declarations
data "http" "request" {
  url = var.url

  insecure = true

  request_headers = {
    Accept = "application/json"
  }

  retry {
    attempts = 3
  }
}
