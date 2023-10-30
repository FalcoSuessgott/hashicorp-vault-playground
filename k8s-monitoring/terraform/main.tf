# Install VAI via Helm
resource "helm_release" "prometheus" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  values = [templatefile(
    "${path.module}/../templates/values.yml",
    {
      minikube_ip = var.minikube_ip
    }
  )]
}

resource "kubernetes_secret" "ca_cert" {
  metadata {
    name      = "ca-cert"
    namespace = helm_release.prometheus.namespace
  }

  data = {
    "ca.crt" = var.ca_cert
  }
}
