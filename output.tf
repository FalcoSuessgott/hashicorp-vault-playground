output "ca_cert" {
  value = module.tls.ca_cert
}

output "minikube_ip" {
  value = module.minikube[0].minikube_ip
}