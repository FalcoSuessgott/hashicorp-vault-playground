
resource "local_file" "dashboard" {
  filename = "${path.module}/../output/dashboard_ingress.yml"
  content = templatefile("${path.module}/../templates/dashboard_ingress.yml", {
    minikube_ip = var.minikube_ip
  })
}

resource "kubectl_manifest" "dashboard" {
  yaml_body = local_file.dashboard.content

  depends_on = [helm_release.cm]
}
