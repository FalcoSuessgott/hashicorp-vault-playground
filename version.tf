terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.24.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "1.1.0"
    }
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "0.3.10"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.10.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.14"
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
  token        = module.vault.root_token
  ca_cert_file = "${path.root}/vault-tls/output/ca.crt"
}

provider "kubernetes" {
  host                   = try(module.minikube[0].kubeconfig.host, null)
  client_certificate     = try(module.minikube[0].kubeconfig.client_certificate, null)
  client_key             = try(module.minikube[0].kubeconfig.client_key, null)
  cluster_ca_certificate = try(module.minikube[0].kubeconfig.cluster_ca_certificate, null)
}

provider "kubectl" {
  apply_retry_count = 3

  host                   = try(module.minikube[0].kubeconfig.host, null)
  client_certificate     = try(module.minikube[0].kubeconfig.client_certificate, null)
  client_key             = try(module.minikube[0].kubeconfig.client_key, null)
  cluster_ca_certificate = try(module.minikube[0].kubeconfig.cluster_ca_certificate, null)

  load_config_file = false
}


provider "helm" {
  kubernetes {
    host                   = try(module.minikube[0].kubeconfig.host, null)
    client_certificate     = try(module.minikube[0].kubeconfig.client_certificate, null)
    client_key             = try(module.minikube[0].kubeconfig.client_key, null)
    cluster_ca_certificate = try(module.minikube[0].kubeconfig.cluster_ca_certificate, null)
  }
}

# Uncomment for the Boundary Lab
provider "boundary" {
  addr = "http://127.0.0.1:9200"
  recovery_kms_hcl = try(<<EOT
kms "transit" {
  purpose            = "recovery"
  address            = "https://127.0.0.1:443"
  disable_renewal    = "false"
  token = "${module.vault.root_token}"
  key_name           = "boundary_recovery"
  mount_path         = "boundary/"
  tls_skip_verify    = "false"
  tls_ca_cert = "${path.root}/vault-tls/output/ca.crt"
}
EOT
  , null)
}
