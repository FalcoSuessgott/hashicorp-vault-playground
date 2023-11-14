resource "docker_container" "boundary" {
  name  = "boundary"
  image = "hashicorp/boundary:0.15"

  env = [
    "VAULT_TOKEN=${vault_token.this.client_token}"
  ]

  capabilities {
    add = [
      "IPC_LOCK",
    ]
  }

  ports {
    internal = 9200
    external = 9200
    ip       = "0.0.0.0"
  }

  ports {
    internal = 9201
    external = 9201
    ip       = "0.0.0.0"
  }

  ports {
    internal = 9202
    external = 9202
    ip       = "0.0.0.0"
  }

  volumes {
    host_path      = abspath("${path.root}/vault-tls/output")
    container_path = "/opt/tls/"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.module}/../files/config.hcl")
    container_path = "/boundary/config.hcl"
    read_only      = true
  }

  command = ["server", "-config", "/boundary/config.hcl"]

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  networks_advanced {
    name = data.docker_network.vault.name
  }

  lifecycle {
    ignore_changes = all
  }

  depends_on = [terraform_data.wait_for]
}
