
data "docker_network" "vault" {
  name = "vault"
}

resource "docker_container" "ubuntu" {
  name  = "ubuntu"
  image = "ubuntu:latest"

  command = ["/usr/bin/sh", "/files/init.sh"]

  volumes {
    host_path      = abspath("${path.root}/vault-tls/output")
    container_path = "/opt/tls/"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.root}/vault-ssh/files")
    container_path = "/files"
    read_only      = true
  }

  networks_advanced {
    name = data.docker_network.vault.name
  }

  lifecycle {
    ignore_changes = all
  }

  depends_on = [vault_ssh_secret_backend_ca.this]
}

resource "vault_mount" "ssh" {
  type = "ssh"
  path = "ssh-client-signer"
}

resource "vault_ssh_secret_backend_ca" "this" {
  backend              = vault_mount.ssh.path
  generate_signing_key = true
}

resource "vault_ssh_secret_backend_role" "ubuntu" {
  name                    = "ubuntu"
  backend                 = vault_mount.ssh.path
  key_type                = "ca"
  allow_user_certificates = true
  allowed_users           = "ubuntu"
  default_user            = "ubuntu"
  default_extensions = {
    "permit-pty" : ""
  }
}