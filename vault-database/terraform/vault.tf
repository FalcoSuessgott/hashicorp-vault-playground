resource "vault_mount" "this" {
  path = "databases"
  type = "database"
}

resource "vault_database_secret_backend_connection" "mysql" {
  backend       = vault_mount.this.path
  name          = "mysql"
  allowed_roles = ["mysql"]

  mysql {
    username = var.database.username
    password = var.database.password
    // no spaces important!
    connection_url = "{{username}}:{{password}}@tcp(${docker_container.mysql.name}:3306)/${var.database.name}"
  }

  # wait until mysql can accept connections
  depends_on = [terraform_data.wait_for]
}

resource "vault_database_secret_backend_role" "mysql" {
  backend = vault_mount.this.path
  name    = "mysql"
  db_name = vault_database_secret_backend_connection.mysql.name
  creation_statements = [
    // no spaces important!
    "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';"
  ]

  revocation_statements = [
    "DROP USER IF EXISTS '{{name}}'@'%';"
  ]

  default_ttl = 60
}
