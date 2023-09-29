resource "docker_network" "network" {
  name     = "vault"
  internal = false

  ipam_config {
    subnet = var.vault.ip_subnet
  }
}
