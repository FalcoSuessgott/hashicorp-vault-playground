resource "local_file" "haproxy" {
  count = var.haproxy.enabled ? 1 : 0

  content = templatefile("./files/haproxy.cfg.tmpl", {
    vaults = local.vault
  })

  filename = "./haproxy/haproxy.cfg"
}

resource "docker_container" "haproxy" {
  count = var.haproxy.enabled ? 1 : 0

  name  = "haproxy"
  image = "haproxy:latest"

  ports {
    internal = 443
    external = var.haproxy.port
    ip       = "0.0.0.0"
  }

  volumes {
    host_path      = abspath(local_file.haproxy[0].filename)
    container_path = "/usr/local/etc/haproxy/haproxy.cfg"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.network.name
  }

  lifecycle {
    ignore_changes = all
  }
}
