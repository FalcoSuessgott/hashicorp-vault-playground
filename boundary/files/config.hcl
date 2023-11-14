# Disable memory lock: https://www.man7.org/linux/man-pages/man2/mlock.2.html
disable_mlock = true

# Controller configuration block
controller {
  name = "default"
  description = "Boundary Default Controller"

  database {
    url = "postgresql://postgres:postgres@postgres:5432/postgres?sslmode=disable"
    max_open_connections = 5
  }
}

worker {
  name = "localhost worker"
  description = "boundary localhost worker"
  public_addr = "127.0.0.1"
}

listener "tcp" {
  # Should be the address of the NIC that the controller server will be reached on
  address = "0.0.0.0"
  purpose = "api"
  tls_disable = true
}

listener "tcp" {
  # Should be the IP of the NIC that the worker will connect on
  address = "boundary"
  purpose = "cluster"
  tls_disable = true
}

listener "tcp" {
  address = "boundary"
  purpose = "proxy"
  tls_disable = true
}

# Root KMS configuration block: this is the root key for Boundary
kms "transit" {
  purpose            = "root"
  address            = "https://host.docker.internal:443"
  disable_renewal    = "false"
  key_name           = "boundary_root"
  mount_path         = "boundary/"
  tls_ca_cert        = "/opt/tls/ca.crt"
}

# Recovery KMS block: configures the recovery key for Boundary
kms "transit" {
  purpose            = "recovery"
  address            = "https://host.docker.internal:443"
  disable_renewal    = "false"
  key_name           = "boundary_recovery"
  mount_path         = "boundary/"
  tls_ca_cert        = "/opt/tls/ca.crt"
}

# Worker authorization KMS
kms "transit" {
  purpose            = "worker-auth"
  address            = "https://host.docker.internal:443"
  disable_renewal    = "false"
  key_name           = "boundary_worker"
  mount_path         = "boundary/"
  tls_ca_cert        = "/opt/tls/ca.crt"
}
