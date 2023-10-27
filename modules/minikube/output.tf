output "kubeconfig" {
  value = {
    host                   = minikube_cluster.docker.host
    client_certificate     = minikube_cluster.docker.client_certificate
    client_key             = minikube_cluster.docker.client_key
    cluster_ca_certificate = minikube_cluster.docker.cluster_ca_certificate
  }
}

output "minikube_ip" {
  value = split(":", regex("^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?", minikube_cluster.docker.host).authority)[0]
}
