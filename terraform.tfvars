vault = {
  ip_settings        = "172.16.10.0/24"
  vault_enterprise   = false
  vault_version      = "1.15"
  vault_nodes        = 3
  autounseal_enabled = false
  keys = {
    shares    = 5
    threshold = 3
  }
}

haproxy = {
  enabled = true
}

prometheus = {
  enabled = true
}

grafana = {
  enabled = true
}
