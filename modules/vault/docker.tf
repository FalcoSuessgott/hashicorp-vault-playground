resource "docker_network" "network" {
  name     = "vault"
  internal = false

  ipam_config {
    subnet = var.ip_subnet
  }
}
