path "csi/" {
  capabilities = ["read", "list"]
}

path "csi/*" {
  capabilities = ["read", "list"]
}
