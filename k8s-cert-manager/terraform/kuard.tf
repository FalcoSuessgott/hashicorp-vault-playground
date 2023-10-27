resource "kubectl_manifest" "kuard" {
  yaml_body = file("${path.module}/../files/kuard.yml")

  depends_on = [helm_release.cm]
}

resource "kubectl_manifest" "kuard_svc" {
  yaml_body = file("${path.module}/../files/kuard_svc.yml")

  depends_on = [helm_release.cm]
}
