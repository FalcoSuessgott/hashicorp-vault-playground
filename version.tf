terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.12.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "1.1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }

  }
}

provider "terracurl" {}
provider "local" {}
provider "tls" {}
provider "time" {}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
