resource "vault_policy" "kms" {
  count = var.kms_enabled ? 1 : 0

  name = "kms"

  policy = file("${path.module}/../files/vault-policy.hcl")
}

resource "kubernetes_secret" "ca_cert" {
  metadata {
    name      = "ca-cert"
    namespace = "kube-system"
  }

  data = {
    "ca.crt" = var.ca_cert
  }
}

resource "vault_kubernetes_auth_backend_role" "kms" {
  backend                          = vault_auth_backend.minikube.path
  role_name                        = "kms"
  bound_service_account_names      = ["default"]
  bound_service_account_namespaces = ["kube-system"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.kms[0].name]
}

resource "vault_mount" "transit" {
  count = var.kms_enabled ? 1 : 0

  path = "transit"
  type = "transit"
}

resource "vault_transit_secret_backend_key" "key" {
  count = var.kms_enabled ? 1 : 0

  backend = vault_mount.transit[0].path
  name    = "kms"

  deletion_allowed = true
}

resource "vault_token" "this" {
  count = var.kms_enabled ? 1 : 0

  policies = [vault_policy.kms[0].name]

  renewable = true
  no_parent = true
  period    = "24h"
  ttl       = "24h"
}
