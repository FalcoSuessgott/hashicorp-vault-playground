vault = {
  # Number of Vault Nodes in Cluster
  nodes = 3

  # docker network CIDR
  ip_subnet = "172.16.10.0/24"

  # Vault Version
  version = "1.15"

  # baseport where the vault container are exposed to localhost
  base_port = 8000

  # Number of Keys & Shares during Initialization & Unsealing
  initialization = {
    shares    = 5
    threshold = 3
  }
}

# Minikube Configuration
minikube = {
  # wether to enable minikube deployment
  enabled = true

  # enable lab: external secrets manager
  external_secrets_manager = true
}
