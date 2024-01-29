terraform {
  required_version = ">= 1.6.0"

  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "0.3.8"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.24.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
