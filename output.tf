output "ca_cert" {
  sensitive = true
  value     = module.tls.ca.cert
}

output "minikube_ip" {
  value = module.minikube[0].minikube_ip
}
