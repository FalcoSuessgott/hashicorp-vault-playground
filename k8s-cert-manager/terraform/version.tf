terraform {
  required_version = ">= 1.6.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}
