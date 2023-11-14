resource "kubernetes_config_map" "this" {
  count = var.kms_enabled ? 1 : 0

  metadata {
    name      = "trousseau-config"
    namespace = "kube-system"
  }

  data = {
    cfg = templatefile("${path.module}/../templates/trousseau-config.yml.tmpl", {
      token = vault_token.this[0].client_token
    })
  }

}

resource "kubectl_manifest" "secret_store" {
  count = var.kms_enabled ? 1 : 0


  yaml_body = file("${path.module}/../files/trousseau.yml")

  depends_on = [kubernetes_config_map.this]
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


resource "vault_policy" "kms" {
  count = var.kms_enabled ? 1 : 0

  name = "kms"

  policy = file("${path.module}/../files/vault-policy.hcl")
}

resource "vault_token" "this" {
  count = var.kms_enabled ? 1 : 0

  policies = [vault_policy.kms[0].name]

  renewable = true
  no_parent = true
  period    = "24h"
  ttl       = "24h"
}
