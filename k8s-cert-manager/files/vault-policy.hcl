path "cert-manager-intermediate" {
  capabilities = ["read", "list"]
}

path "cert-manager-intermediate/sign/nip-io" {
  capabilities = ["create", "update"]
}

path "cert-manager-intermediate/issue/nip-io" {
  capabilities = ["create"]
}
