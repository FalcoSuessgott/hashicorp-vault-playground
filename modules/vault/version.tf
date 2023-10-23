terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "1.1.0"
    }
  }
}
