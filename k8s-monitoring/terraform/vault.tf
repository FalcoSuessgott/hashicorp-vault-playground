resource "vault_policy" "prometheus" {
  name = "prometheus"

  policy = file("${path.module}/../files/vault-policy.hcl")
}


resource "vault_token" "prometheus" {
  policies = [vault_policy.prometheus.name]

  renewable = true
  period    = "24h"
  no_parent = true
}

resource "kubernetes_secret" "token" {
  metadata {
    name      = "token"
    namespace = helm_release.prometheus.namespace
  }

  data = {
    "token" = vault_token.prometheus.client_token
  }
}
