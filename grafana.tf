resource "local_file" "grafana" {
  count = var.grafana.enabled ? 1 : 0

  content = templatefile("./files/grafana.yml.tmpl", {
    prometheus_ip   = cidrhost(var.vault.ip_subnet, 20)
    prometheus_port = var.prometheus.port
  })

  filename = "./grafana/grafana.yml"
}

resource "docker_container" "grafana" {
  count = var.grafana.enabled ? 1 : 0

  name  = "grafana"
  image = "grafana/grafana:latest"

  ports {
    internal = 3000
    external = var.grafana.port
    ip       = "0.0.0.0"
  }

  volumes {
    host_path      = abspath(local_file.grafana[0].filename)
    container_path = "/etc/grafana/provisioning/datasources/prometheus_datasource.yml"
    read_only      = true
  }

  volumes {
    host_path      = abspath("./grafana/dashboard.yml")
    container_path = "/etc/grafana/provisioning/dashboards/vault.yml"
    read_only      = true
  }

  volumes {
    host_path      = abspath("./grafana/vault_dashboard.json")
    container_path = "/var/lib/grafana/dashboards/vault_dashboard.json"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.network.name
  }

  lifecycle {
    ignore_changes = all
  }
}
