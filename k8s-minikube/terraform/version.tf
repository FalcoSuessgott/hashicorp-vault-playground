terraform {
  required_version = ">= 1.6.0"

  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "0.3.10"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.28.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
