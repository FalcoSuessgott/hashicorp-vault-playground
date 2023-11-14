locals {
  secret_name = "${var.service_account_name}-token-secret"
}

resource "kubernetes_service_account" "service_account" {
  automount_service_account_token = false

  metadata {
    name      = var.service_account_name
    namespace = var.namespace
  }

  secret {
    name = local.secret_name
  }
}

resource "kubernetes_secret" "service_account_secret" {
  metadata {
    name      = local.secret_name
    namespace = var.namespace

    annotations = {
      "kubernetes.io/service-account.name"      = kubernetes_service_account.service_account.metadata[0].name
      "kubernetes.io/service-account.namespace" = var.namespace
    }
  }

  type = "kubernetes.io/service-account-token"
}

# https://developer.hashicorp.com/vault/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt
resource "kubernetes_cluster_role_binding" "sa_validator" {
  metadata {
    name = "vault-token-reviewer"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.service_account.metadata[0].name
    namespace = "default"
  }
}


# enable vault kubernetes auth backend for minikube cluster
resource "vault_auth_backend" "minikube" {
  type = "kubernetes"
  path = "minikube-cluster"
}

# configure vault kubernetes auth backend
resource "vault_kubernetes_auth_backend_config" "this" {
  backend = vault_auth_backend.minikube.path

  kubernetes_host    = "https://host.docker.internal:8443"
  kubernetes_ca_cert = kubernetes_secret.service_account_secret.data["ca.crt"]
  token_reviewer_jwt = kubernetes_secret.service_account_secret.data.token
}
