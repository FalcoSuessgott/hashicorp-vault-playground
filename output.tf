output "ca_cert" {
  value = module.tls.ca.cert
}

output "minikube_ip" {
  value = try(module.minikube[0].minikube_ip, "")
}

output "root_token" {
  value = module.vault.root_token
}

output "unseal_keys" {
  value = module.vault.unseal_keys
}
