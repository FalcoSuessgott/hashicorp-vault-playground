data "docker_network" "vault" {
  name = "vault"
}

resource "docker_container" "postgres" {
  name  = "postgres"
  image = "postgres:12.17"

  env = [
    "POSTGRES_PASSWORD=postgres",
    "POSTGRES_USER=postgres",
  ]

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

# improve this, so that the container is not created every apply
resource "docker_container" "db_init" {
  name  = "boundary_db_init"
  image = "hashicorp/boundary:0.15"

  env = [
    "BOUNDARY_POSTGRES_URL=postgresql://postgres:postgres@${docker_container.postgres.name}:5432/postgres?sslmode=disable",
    "VAULT_TOKEN=${vault_token.this.client_token}"
  ]

  capabilities {
    add = [
      "IPC_LOCK",
    ]
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

  command = ["database", "init",
    "-skip-auth-method-creation", "-skip-host-resources-creation",
    "-skip-scopes-creation", "-skip-target-creation",
    "-config", "/boundary/config.hcl"
  ]

  # allow vault access localhost
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
}

resource "terraform_data" "wait_for" {
  provisioner "local-exec" {
    command = <<EOT
  until docker logs ${docker_container.db_init.name} | grep "Global-scope KMS keys successfully created." ; do
    echo "Postgresql migration not done yet - waiting for it..."
  sleep 1
done
EOT
  }
}
