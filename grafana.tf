# resource "docker_container" "grafana" {
#   count = var.grafana.enabled ? 1 : 0

#   name  = "grafana"
#   image = "grafana/grafana:latest"

#   ports {
#     internal = 3000
#     external = var.grafana.port
#     ip       = "0.0.0.0"
#   }

#   volumes {
#     host_path      = abspath("./grafana/grafana.yml")
#     container_path = "/etc/grafana/provisioning/datasources/prometheus_datasource.yml"
#     read_only      = true
#   }

#   volumes {
#     host_path      = abspath("./grafana/dashboard.yml")
#     container_path = "/etc/grafana/provisioning/dashboards/vault.yml"
#     read_only      = true
#   }

#   volumes {
#     host_path      = abspath("./grafana/vault_dashboard.json")
#     container_path = "/var/lib/grafana/dashboards/vault_dashboard.json"
#     read_only      = true
#   }

#   networks_advanced {
#     name = docker_network.network.name
#   }

#   lifecycle {
#     ignore_changes = all
#   }
# }
