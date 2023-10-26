resource "vault_mount" "vso" {
  path        = "vso"
  type        = "kv"
  options     = { version = "2" }
  description = "Secrets read by Vault Secrets Operator"
}

resource "vault_kv_secret_v2" "vso" {
  mount               = vault_mount.vso.path
  name                = "secrets"
  delete_all_versions = true
  data_json           = jsonencode(var.secrets)
}

resource "vault_policy" "vso" {
  name = "vso"

  policy = file("${path.root}/minikube/vso/vault-policy.hcl")
}

resource "vault_kubernetes_auth_backend_role" "vso" {
  backend                          = "minikube-cluster"
  role_name                        = helm_release.vso.name
  bound_service_account_names      = ["default"]
  bound_service_account_namespaces = [helm_release.vso.name]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.vso.name]
}
