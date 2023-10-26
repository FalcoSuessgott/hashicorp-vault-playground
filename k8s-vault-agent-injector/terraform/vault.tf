resource "vault_mount" "vai" {
  path        = "vai"
  type        = "kv"
  options     = { version = "2" }
  description = "Secrets read by Vault Secrets Operator"
}

resource "vault_kv_secret_v2" "vai" {
  mount               = vault_mount.vai.path
  name                = "secrets"
  delete_all_versions = true
  data_json           = jsonencode(var.secrets)
}

resource "vault_policy" "vai" {
  name = "vai"

  policy = file("${path.module}/../files/vault-policy.hcl")
}

resource "vault_kubernetes_auth_backend_role" "vai" {
  backend                          = "minikube-cluster"
  role_name                        = helm_release.vai.name
  bound_service_account_names      = ["default"]
  bound_service_account_namespaces = [helm_release.vai.namespace]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.vai.name]
}
