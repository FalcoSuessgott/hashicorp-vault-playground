terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.20.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "1.1.0"
    }
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "0.3.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }
  }
}

provider "terracurl" {}
provider "local" {}
provider "tls" {}
provider "time" {}
provider "minikube" {}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "vault" {
  address      = "https://127.0.0.1"
  token        = try(file(".vault_token"), "")
  ca_cert_file = "./vault-tls/output/ca.crt"
}

provider "kubernetes" {
  host                   = module.kubernetes[0].kubeconfig.host
  client_certificate     = module.kubernetes[0].kubeconfig.client_certificate
  client_key             = module.kubernetes[0].kubeconfig.client_key
  cluster_ca_certificate = module.kubernetes[0].kubeconfig.cluster_ca_certificate
}

provider "kubectl" {
  apply_retry_count = 3

  host                   = module.kubernetes[0].kubeconfig.host
  client_certificate     = module.kubernetes[0].kubeconfig.client_certificate
  client_key             = module.kubernetes[0].kubeconfig.client_key
  cluster_ca_certificate = module.kubernetes[0].kubeconfig.cluster_ca_certificate

  load_config_file = false
}


provider "helm" {
  kubernetes {
    host                   = module.kubernetes[0].kubeconfig.host
    client_certificate     = module.kubernetes[0].kubeconfig.client_certificate
    client_key             = module.kubernetes[0].kubeconfig.client_key
    cluster_ca_certificate = module.kubernetes[0].kubeconfig.cluster_ca_certificate
  }
}
