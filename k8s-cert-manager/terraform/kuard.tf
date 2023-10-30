resource "kubectl_manifest" "kuard" {
  yaml_body = file("${path.module}/../files/kuard.yml")

  depends_on = [helm_release.cm]
}

resource "kubectl_manifest" "kuard_svc" {
  yaml_body = file("${path.module}/../files/kuard_svc.yml")

  depends_on = [helm_release.cm]
}

resource "local_file" "ingress" {
  filename = "${path.module}/../output/kuard_ingress.yml"
  content = templatefile("${path.module}/../templates/kuard_ingress.yml", {
    minikube_ip = var.minikube_ip
  })
}

resource "kubectl_manifest" "ingress" {
  yaml_body = local_file.ingress.content

  depends_on = [helm_release.cm]
}
