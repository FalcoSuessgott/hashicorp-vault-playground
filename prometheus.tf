resource "local_file" "prometheus" {
  content = templatefile("./files/prometheus.yml.tmpl", {
    vaults = local.vault
  })
  filename = "./prometheus/prometheus.yml"
}

resource "local_file" "prometheus_token" {
  content  = jsondecode(terracurl_request.init.response).root_token
  filename = "./prometheus/prometheus-token"
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = "prom/prometheus:latest"

  ports {
    internal = 9090
    external = var.prometheus.port
    ip       = "0.0.0.0"
  }

  volumes {
    host_path      = abspath(local_file.prometheus.filename)
    container_path = "/etc/prometheus/prometheus.yml"
    read_only      = true
  }

  volumes {
    host_path      = abspath(local_file.prometheus_token.filename)
    container_path = "/etc/prometheus/prometheus-token"
    read_only      = true
  }

  volumes {
    host_path      = abspath(local_file.ca_cert.filename)
    container_path = "/etc/prometheus/vault_ca_file"
    read_only      = true
  }

  networks_advanced {
    name         = docker_network.network.name
    ipv4_address = cidrhost(var.vault.ip_subnet, 30)
  }

  lifecycle {
    ignore_changes = all
  }
}
