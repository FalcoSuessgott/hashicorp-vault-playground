resource "vault_mount" "esm" {
  path        = "esm"
  type        = "kv"
  options     = { version = "2" }
  description = "Secrets read by External Secrets Manager"
}

resource "vault_kv_secret_v2" "esm" {
  mount               = vault_mount.esm.path
  name                = "secrets"
  delete_all_versions = true
  data_json           = jsonencode(var.secrets)
}

resource "vault_policy" "esm" {
  name = "esm"

  policy = file("${path.module}/../files/vault-policy.hcl")
}

resource "vault_kubernetes_auth_backend_role" "esm" {
  backend                          = "minikube-cluster"
  role_name                        = helm_release.esm.name
  bound_service_account_names      = ["${helm_release.esm.name}-${helm_release.esm.chart}"]
  bound_service_account_namespaces = [helm_release.esm.name]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.esm.name]
}
