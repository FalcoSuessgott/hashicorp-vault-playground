ui = true
disable_mlock = true
api_addr = "https://{{ GetPrivateIP }}:8200"
cluster_addr = "https://{{ GetPrivateIP }}:8201"

listener "tcp" {
  address="0.0.0.0:8200"
  tls_cert_file="/vault/config/vault.crt"
  tls_key_file="/vault/config/vault.key"
}

storage "raft" {
  path = "/vault/file/"

    retry_join {
    leader_api_addr = "https://172.16.10.10:8200"
    leader_ca_cert_file = "/vault/config/ca.crt"
    leader_client_cert_file = "/vault/config/vault.crt"
    leader_client_key_file = "/vault/config/vault.key"
  }
    retry_join {
    leader_api_addr = "https://172.16.10.11:8200"
    leader_ca_cert_file = "/vault/config/ca.crt"
    leader_client_cert_file = "/vault/config/vault.crt"
    leader_client_key_file = "/vault/config/vault.key"
  }
    retry_join {
    leader_api_addr = "https://172.16.10.12:8200"
    leader_ca_cert_file = "/vault/config/ca.crt"
    leader_client_cert_file = "/vault/config/vault.crt"
    leader_client_key_file = "/vault/config/vault.key"
  }

}

telemetry {
  disable_hostname = true
  prometheus_retention_time = "12h"
}
