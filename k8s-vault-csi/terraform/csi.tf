resource "helm_release" "csi" {
  name       = "csi"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "csi"

  set {
    name  = "syncSecret.enabled"
    value = true
  }

  depends_on = [helm_release.vault]
}

resource "kubectl_manifest" "secret_provider_class" {
  yaml_body = file("${path.module}/../files/secret_provider_class.yml")

  depends_on = [helm_release.csi]
}
