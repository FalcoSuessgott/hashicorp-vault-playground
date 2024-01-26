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

  # enable kms plugin for secret encryption at rest
  kms = false

  # enable external secrets manager
  external_secrets_manager = true

  # enable vault secrets operator
  vault_secrets_operator = true

  # enable secrets using the CSI driver
  csi = true

  # enable cert manager
  cert_manager = true

  # enable vault agent injector
  vault_agent_injector = true
}
