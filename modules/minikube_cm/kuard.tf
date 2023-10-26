resource "kubectl_manifest" "kuard" {
  yaml_body = file("${path.root}/minikube/cm/kuard.yml")

  depends_on = [helm_release.cm]
}

resource "kubectl_manifest" "kuard_svc" {
  yaml_body = file("${path.root}/minikube/cm/kuard_svc.yml")

  depends_on = [helm_release.cm]
}