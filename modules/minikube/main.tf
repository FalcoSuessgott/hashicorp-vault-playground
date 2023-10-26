resource "minikube_cluster" "docker" {
  driver       = "docker"
  cluster_name = "vault-playground"
  cni          = "bridge"

  listen_address = "0.0.0.0"

  apiserver_names = [
    "host.docker.internal"
  ]

  ports = [
    "8443:8443"
  ]

  addons = [
    "dashboard",
    "default-storageclass",
    "storage-provisioner",
    "ingress"
  ]
}
