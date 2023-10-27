ui = true
disable_mlock = true
api_addr = "https://{{ GetPrivateIP }}:8200"
cluster_addr = "https://{{ GetPrivateIP }}:8201"

listener "tcp" {
  address="0.0.0.0:8200"
  tls_cert_file="/opt/tls/vault.crt"
  tls_key_file="/opt/tls/vault.key"
}

storage "raft" {
  path = "/vault/file/"

%{ for name, cfg in vaults ~}
  retry_join {
    leader_api_addr = "https://${name}:8200"
    leader_ca_cert_file = "/opt/tls/ca.crt"
    leader_client_cert_file = "/opt/tls/vault.crt"
    leader_client_key_file = "/opt/tls/vault.key"
  }
%{ endfor }
}

telemetry {
  disable_hostname = true
  prometheus_retention_time = "12h"
}
