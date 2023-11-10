data "docker_network" "vault" {
  name = "vault"
}

resource "docker_container" "mysql" {
  name  = "mysql"
  image = "mysql:latest"

  env = [
    "MYSQL_ROOT_PASSWORD=${var.database.password}",
    "MYSQL_DATABASE=${var.database.name}",
  ]

  ports {
    internal = 3306
    external = 3306
    ip       = "0.0.0.0"
  }

  volumes {
    host_path      = abspath("${path.root}/vault-tls/output")
    container_path = "/opt/tls/"
    read_only      = true
  }

  networks_advanced {
    name = data.docker_network.vault.name
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "terraform_data" "wait_for" {
  provisioner "local-exec" {
    command = <<EOT
  until docker container exec -i ${docker_container.mysql.name} mysqladmin ping -P 3306 -proot | grep "mysqld is alive" ; do
    echo "MySQL is unavailable - waiting for it..."
  sleep 1
done
EOT
  }
}
