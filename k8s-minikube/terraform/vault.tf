resource "vault_mount" "transit" {
  path = "transit"
  type = "transit"
}

resource "vault_transit_secret_backend_key" "key" {
  backend = vault_mount.transit.path
  name    = "kms"

  deletion_allowed = true
}

resource "vault_policy" "kms" {
  name = "kms"

  policy = file("${path.module}/../files/vault-policy.hcl")
}

resource "vault_token" "this" {
  policies = [vault_policy.kms.name]

  renewable = true
  no_parent = true
  period    = "24h"
  ttl       = "24h"
}
