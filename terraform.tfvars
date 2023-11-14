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

# Dyanmic DB Credentials
databases = {
  enabled = false

  # enable mysql db
  mysql = true
}

# Minikube Configuration
kubernetes = {
  # wether to enable minikube deployment
  enabled = true

  # enable external secrets manager
  external_secrets_manager = false

  # enable vault secrets operator
  vault_secrets_operator = false

  # enable cert manager
  cert_manager = false

  # enable vault agent injector
  vault_agent_injector = false
}

# enable Boundary Lab
boundary = {
  enabled = true
}
