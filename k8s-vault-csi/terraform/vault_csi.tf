resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "csi"
  create_namespace = true

  values = [file("${path.module}/../files/values.yml")]
}

resource "kubernetes_secret" "ca_cert" {
  metadata {
    name      = "ca-cert"
    namespace = helm_release.vault.namespace
  }

  data = {
    "ca.crt" = var.ca_cert
  }
}

# Create a SA Secret for default SA
resource "kubernetes_secret" "sa_secret" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = "default"
    }
    namespace     = helm_release.vault.namespace
    generate_name = "${helm_release.vault.name}-${helm_release.vault.chart}-token-"
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}
