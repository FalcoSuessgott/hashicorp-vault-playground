resource "vault_kubernetes_secret_backend" "config" {
  path        = "minikube"
  description = "K8s SAs for Minikube Cluster"

  default_lease_ttl_seconds = 43200
  max_lease_ttl_seconds     = 86400

  kubernetes_host     = vault_kubernetes_auth_backend_config.this.kubernetes_host
  kubernetes_ca_cert  = vault_kubernetes_auth_backend_config.this.kubernetes_ca_cert
  service_account_jwt = vault_kubernetes_auth_backend_config.this.token_reviewer_jwt

  disable_local_ca_jwt = false
}

resource "vault_kubernetes_secret_backend_role" "role" {
  backend = vault_kubernetes_secret_backend.config.path
  name    = "minikube"

  allowed_kubernetes_namespaces = ["*"]
  token_max_ttl                 = 43200
  token_default_ttl             = 21600

  generated_role_rules = <<EOT
{"rules":[{"apiGroups":[""],"resources":["pods"],"verbs":["list"]}]}
EOT
}


# https://www.hashicorp.com/blog/how-to-connect-to-kubernetes-clusters-using-boundary
resource "kubernetes_cluster_role" "sa_creator" {
  metadata {
    name = "k8s-secret-method"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts", "serviceaccounts/token"]
    verbs      = ["create", "update", "delete"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["rolebindings", "clusterrolebindings"]
    verbs      = ["create", "update", "delete"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "clusterroles"]
    verbs      = ["bind", "escalate", "create", "update", "delete"]
  }
}


resource "kubernetes_cluster_role_binding" "toke_creator" {
  metadata {
    name = "vault-token-creator-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.sa_creator.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.service_account.metadata[0].name
    namespace = "default"
  }
}
