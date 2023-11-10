resource "kubectl_manifest" "kuard" {
  yaml_body = file("${path.module}/../files/kuard.yml")

  depends_on = [helm_release.vai]
}
