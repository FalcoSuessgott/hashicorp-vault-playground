output "summary" {
  value = {
    vault = {
      root_token   = jsondecode(terracurl_request.init.response).root_token
      unseal_keys  = !var.vault.autounseal_enabled ? jsondecode(terracurl_request.init.response).keys_base64 : null
      url          = "https://127.0.0.1"
      ca_cert_file = local_file.ca_cert.filename
      cert_file    = local_file.vault_cert.filename
      key_file     = local_file.vault_priv_key.filename
    }

    prometheus = {
      url = "https://127.0.0.1:${var.prometheus.port}"
    }

    grafana = {
      username = "admin"
      password = "admin"
      url      = "http://127.0.0.1:${var.grafana.port}"
    }
  }
}
