locals {
  vault = {
    for v in range(0, var.vault.vault_nodes) : format("vault-%02d", v + 1) => {
      port = 8000 + (v + 1)
      ip   = cidrhost(var.vault.ip_subnet, 10 + v)
    }
  }
}

resource "local_file" "vault" {
  content = templatefile("./files/vault.tmpl.hcl", {
    vaults = local.vault
  })

  filename = "./vault/vault.hcl"
}

resource "docker_container" "vault" {
  for_each = local.vault

  name  = each.key
  image = "hashicorp/vault:${var.vault.vault_version}"

  env = [
    "VAULT_ADDR=https://0.0.0.:8200",
    "VAULT_RAFT_NODE_ID=${each.key}",
  ]

  capabilities {
    add = [
      "IPC_LOCK",
    ]
  }

  ports {
    internal = 8200
    external = each.value.port
    ip       = "0.0.0.0"
  }

  volumes {
    host_path      = abspath("./vault")
    container_path = "/vault/config"
    read_only      = true
  }


  command = ["server"]

  networks_advanced {
    name         = docker_network.network.name
    ipv4_address = each.value.ip
  }

  depends_on = [
    local_file.ca_cert,
    local_file.vault_priv_key,
    local_file.vault_cert
  ]

  lifecycle {
    ignore_changes = all
  }
}


resource "terracurl_request" "init" {
  name   = "vault-init"
  url    = "https://127.0.0.1:${[for v in local.vault : v.port][0]}/v1/sys/init"
  method = "POST"

  # https://developer.hashicorp.com/vault/api-docs/system/init
  request_body = jsonencode({
    secret_shares      = !var.vault.autounseal_enabled ? var.vault.keys.shares : null
    secret_threshold   = !var.vault.autounseal_enabled ? var.vault.keys.threshold : null
    recovery_shares    = var.vault.autounseal_enabled ? var.vault.keys.shares : null
    recovery_threshold = var.vault.autounseal_enabled ? var.vault.keys.threshold : null
  })

  response_codes = [200, 204]

  ca_cert_file = local_file.ca_cert.filename
  key_file     = local_file.vault_priv_key.filename
  cert_file    = local_file.vault_cert.filename

  retry_interval = 5
  max_retry      = 3

  depends_on = [docker_container.vault]
}

resource "local_file" "vault_token" {
  content  = jsondecode(terracurl_request.init.response).root_token
  filename = ".vault_token"
}

locals {
  unseals = flatten([
    for k, v in local.vault : [
      for index in range(0, var.vault.keys.threshold) : merge(v, {
        node  = k
        index = index
        key   = jsondecode(terracurl_request.init.response).keys[index]
      })
    ]
  ])
}

resource "terracurl_request" "unseal" {
  for_each = { for u in local.unseals : format("%s-unseal-%02d", u.node, u.index) => u }

  name   = each.key
  url    = "https://127.0.0.1:${each.value.port}/v1/sys/unseal"
  method = "POST"

  # https://developer.hashicorp.com/vault/api-docs/system/init
  request_body = jsonencode({
    key = each.value.key
  })

  response_codes = [200, 204]

  ca_cert_file = local_file.ca_cert.filename
  key_file     = local_file.vault_priv_key.filename
  cert_file    = local_file.vault_cert.filename

  retry_interval = 5
  max_retry      = 3
  depends_on     = [terracurl_request.init]
}
