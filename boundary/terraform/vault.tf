resource "vault_mount" "transit" {
  path                      = "boundary"
  type                      = "transit"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_transit_secret_backend_key" "keys" {
  for_each         = toset(["boundary_root", "boundary_worker", "boundary_recovery"])
  backend          = vault_mount.transit.path
  name             = each.key
  deletion_allowed = true
}

resource "vault_policy" "this" {
  name = "boundary"

  policy = file("${path.module}/../files/vault-policy.hcl")

  depends_on = [vault_transit_secret_backend_key.keys]
}

resource "vault_token" "this" {
  policies = [vault_policy.this.name]

  renewable = true
  no_parent = true
  period    = "24h"
}
