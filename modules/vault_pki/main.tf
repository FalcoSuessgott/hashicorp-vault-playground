# 1. enable pki secret engine
resource "vault_mount" "intermediate" {
  path = "cert-manager-intermediate"
  type = "pki"
}

# 2. create csr for an intermediate ca
resource "vault_pki_secret_backend_intermediate_cert_request" "csr" {
  backend = vault_mount.intermediate.path
  type    = "internal"

  common_name  = "nip.io"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = "Vault"
  organization = "HashiCorp"
  country      = "DE"
  locality     = "Berlin"
  province     = "Berlin"
}

# 3. sign the csr with the root ca certificate
resource "tls_locally_signed_cert" "sign_csr" {
  cert_request_pem   = vault_pki_secret_backend_intermediate_cert_request.csr.csr
  ca_private_key_pem = var.priv_key
  ca_cert_pem        = var.ca_cert

  validity_period_hours = 86000

  is_ca_certificate = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "server_auth",
  ]
}

# 4. set the intermediate certificate for the pki secret engine
resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.intermediate.path
  certificate = tls_locally_signed_cert.sign_csr.cert_pem
}

// 5. create a role for issuing certs bound to a specific subdomain
resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.intermediate.path
  name             = "nip-io"
  ttl              = 3600
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 2048
  allowed_domains  = ["nip.io"]
  allow_subdomains = true
  require_cn       = false
}
