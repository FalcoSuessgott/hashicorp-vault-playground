resource "docker_network" "vault" {
  name     = "vault"
  internal = false

  ipam_config {
    subnet = var.ip_subnet
  }
}
