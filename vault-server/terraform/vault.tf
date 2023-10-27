locals {
  vaults = {
    for v in range(0, var.vault_nodes) : format("vault-%02d", v + 1) => {
      port = var.base_port + (v + 1)
      ip   = cidrhost(var.ip_subnet, 10 + v)
    }
  }
}

resource "local_file" "vault" {
  content = templatefile("${path.module}/../templates/vault.hcl", {
    vaults = local.vaults
  })

  filename = "${path.module}/../output/vault.hcl"
}

resource "docker_container" "vault" {
  for_each = local.vaults

  name  = each.key
  image = "hashicorp/vault:${var.vault_version}"

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
    host_path      = abspath(local_file.vault.filename)
    container_path = "/vault/config/vault.hcl"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.root}/vault-tls/output")
    container_path = "/opt/tls/"
    read_only      = true
  }

  command = ["server"]

  # allow vault access localhost
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  networks_advanced {
    name         = docker_network.network.name
    ipv4_address = each.value.ip
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "terracurl_request" "init" {
  name = "vault-init"
  # we cannot initialize via LB port since we have the Vault Health Check enabled
  # which redirects requests to a leader, but we dont have one yet
  url    = "https://127.0.0.1:${[for v in local.vaults : v.port][0]}/v1/sys/init"
  method = "POST"

  # https://developer.hashicorp.com/vault/api-docs/system/init
  request_body = jsonencode({
    secret_shares    = var.initialization.shares
    secret_threshold = var.initialization.threshold
  })

  response_codes = [200, 204]

  ca_cert_file = "${path.root}/vault-tls/output/ca.crt"
  key_file     = "${path.root}/vault-tls/output/vault.key"
  cert_file    = "${path.root}/vault-tls/output/vault.crt"

  retry_interval = 5
  max_retry      = 3

  depends_on = [
    docker_container.vault,
  ]
}

resource "local_file" "vault_token" {
  content  = jsondecode(terracurl_request.init.response).root_token
  filename = ".vault_token"
}

locals {
  unseals = flatten([
    for k, v in local.vaults : [
      for index in range(0, var.initialization.threshold) : merge(v, {
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

  # https://developer.hashicorp.com/vault/api-docs/system/unseal
  request_body = jsonencode({
    key = each.value.key
  })

  response_codes = [200, 204]

  ca_cert_file = "${path.root}/vault-tls/output/ca.crt"
  key_file     = "${path.root}/vault-tls/output/vault.key"
  cert_file    = "${path.root}/vault-tls/output/vault.crt"

  retry_interval = 5
  max_retry      = 3

  depends_on = [terracurl_request.init]
}
