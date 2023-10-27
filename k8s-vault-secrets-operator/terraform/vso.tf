resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "vso"
  }
}

resource "kubernetes_secret" "ca_cert" {
  metadata {
    name      = "ca-cert"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }

  data = {
    "ca.crt" = var.ca_cert
  }
}

# Install VSO via Helm
resource "helm_release" "vso" {
  name       = "vso"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  namespace  = kubernetes_namespace_v1.ns.metadata[0].name

  values = [file("${path.module}/../files/values.yml")]

  depends_on = [kubernetes_secret.ca_cert]
}

# Create a SA Secret for default SA
resource "kubernetes_secret" "sa_secret" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = "default"
    }
    namespace     = helm_release.vso.name
    generate_name = "${helm_release.vso.name}-${helm_release.vso.chart}-token-"
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

# Apply VaultAuth CRD
resource "kubectl_manifest" "vault_auth" {
  yaml_body = file("${path.module}/../files/vault_auth.yml")

  depends_on = [helm_release.vso]
}

# Apply Secret Store CRD
resource "kubectl_manifest" "vault_static_secret" {
  yaml_body = file("${path.module}/../files/vault_static_secret.yml")

  depends_on = [helm_release.vso]
}
