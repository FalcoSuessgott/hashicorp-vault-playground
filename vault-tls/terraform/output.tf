output "ca" {
  value = {
    cert = tls_self_signed_cert.root_cert.cert_pem
    key  = tls_private_key.priv_key.private_key_pem
  }
}

output "vault" {
  value = {
    cert = "${tls_locally_signed_cert.sign_csr.cert_pem}${tls_self_signed_cert.root_cert.cert_pem}"
    key  = tls_private_key.vault_priv_key.private_key_pem
  }
}
