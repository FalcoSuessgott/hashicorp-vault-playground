resource "vault_mount" "csi" {
  path        = "csi"
  type        = "kv"
  options     = { version = "2" }
  description = "Secrets read by Vault CSI Driver"
}

resource "vault_kv_secret_v2" "csi" {
  mount               = vault_mount.csi.path
  name                = "secrets"
  delete_all_versions = true
  data_json           = jsonencode(var.secrets)
}

resource "vault_policy" "csi" {
  name = "csi"

  policy = file("${path.module}/../files/vault-policy.hcl")
}

resource "vault_kubernetes_auth_backend_role" "csi" {
  backend                          = "minikube-cluster"
  role_name                        = helm_release.csi.name
  bound_service_account_names      = ["default"]
  bound_service_account_namespaces = [helm_release.csi.namespace]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.csi.name]
}
