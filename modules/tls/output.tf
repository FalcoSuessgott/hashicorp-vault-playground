output "ca_cert" {
  value = tls_self_signed_cert.root_cert.cert_pem
}

output "key" {
  sensitive = true
  value     = tls_private_key.vault_priv_key.private_key_pem
}

output "cert" {
  value = "${tls_locally_signed_cert.sign_csr.cert_pem}${tls_self_signed_cert.root_cert.cert_pem}"
}
