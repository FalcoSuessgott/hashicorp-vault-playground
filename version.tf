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
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.10"
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
  host                   = try(module.kubernetes[0].kubeconfig.host, null)
  client_certificate     = try(module.kubernetes[0].kubeconfig.client_certificate, null)
  client_key             = try(module.kubernetes[0].kubeconfig.client_key, null)
  cluster_ca_certificate = try(module.kubernetes[0].kubeconfig.cluster_ca_certificate, null)
}

provider "helm" {
  kubernetes {
    host                   = try(module.kubernetes[0].kubeconfig.host, null)
    client_certificate     = try(module.kubernetes[0].kubeconfig.client_certificate, null)
    client_key             = try(module.kubernetes[0].kubeconfig.client_key, null)
    cluster_ca_certificate = try(module.kubernetes[0].kubeconfig.cluster_ca_certificate, null)
  }
}

# provider "boundary" {
#   addr             = "http://127.0.0.1:9200"
#   recovery_kms_hcl = <<EOT
# kms "transit" {
#   purpose            = "recovery"
#   address            = "https://127.0.0.1:443"
#   disable_renewal    = "false"
#   token = "${file(".vault_token")}"
#   key_name           = "boundary_recovery"
#   mount_path         = "transit/"
#   tls_skip_verify    = "false"
#   tls_ca_cert = "${path.root}/vault-tls/output/ca.crt"
# }
# EOT
# }
