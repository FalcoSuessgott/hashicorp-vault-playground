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
