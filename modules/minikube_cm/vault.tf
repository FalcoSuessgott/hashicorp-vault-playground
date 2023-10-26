resource "vault_policy" "cm" {
  name = "cm"

  policy = file("${path.root}/minikube/cm/vault-policy.hcl")
}

resource "vault_kubernetes_auth_backend_role" "cm" {
  backend                          = "minikube-cluster"
  role_name                        = helm_release.cm.name
  bound_service_account_names      = ["vault-issuer"]
  bound_service_account_namespaces = [helm_release.cm.namespace]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.cm.name]
}
