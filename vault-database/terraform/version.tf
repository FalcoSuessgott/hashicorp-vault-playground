terraform {
  required_version = ">= 1.6.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.25.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}
