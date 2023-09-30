# 1. create a private key
resource "tls_private_key" "priv_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

# 2. create a root ca certificate
resource "tls_self_signed_cert" "root_cert" {
  private_key_pem = tls_private_key.priv_key.private_key_pem

  subject {
    common_name = var.ca_cn
  }

  validity_period_hours = 86000

  is_ca_certificate = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "server_auth",
  ]
}

# 3. create a private key for the vault certificate
resource "tls_private_key" "vault_priv_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

# 3. create a csr
resource "tls_cert_request" "csr" {
  private_key_pem = tls_private_key.vault_priv_key.private_key_pem

  subject {
    common_name = var.cert_cn
  }

  dns_names    = var.dns_sans
  ip_addresses = var.ip_sans
}

# 4. sign the csr using the root ca
resource "tls_locally_signed_cert" "sign_csr" {
  cert_request_pem      = tls_cert_request.csr.cert_request_pem
  ca_private_key_pem    = tls_private_key.priv_key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.root_cert.cert_pem
  validity_period_hours = 86000
  is_ca_certificate     = false

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# 5. write certs to vault dir
resource "local_file" "vault_cert" {
  filename = "vault/vault.crt"
  content  = "${tls_locally_signed_cert.sign_csr.cert_pem}${tls_self_signed_cert.root_cert.cert_pem}" #  first server cert, then CA cert
}

# 6. write private key to vault dir
resource "local_file" "vault_priv_key" {
  filename = "vault/vault.key"
  content  = tls_private_key.vault_priv_key.private_key_pem
}

# 7. write ca cert to vault dir
resource "local_file" "ca_cert" {
  filename = "vault/ca.crt"
  content  = tls_self_signed_cert.root_cert.cert_pem
}
