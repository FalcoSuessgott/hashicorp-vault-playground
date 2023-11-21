# Install ESM via Helm
resource "helm_release" "esm" {
  name             = "esm"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "esm"
  create_namespace = true

  values = [file("${path.module}/../files/values.yml")]
}

# Create a SA Secret for ESM SA
resource "kubernetes_secret" "sa_secret" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = "${helm_release.esm.name}-${helm_release.esm.chart}"
    }
    namespace     = helm_release.esm.name
    generate_name = "${helm_release.esm.name}-${helm_release.esm.chart}-token-"
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

# Render SecretStore CRD pointing to Vault
resource "local_file" "secret_store" {
  filename = "${path.module}/../output/secret_store.yml"
  content = templatefile("${path.module}/../templates/secret_store.yml", {
    ca = base64encode(var.ca_cert)
  })
}

# Apply Secret Store CRD
resource "kubectl_manifest" "secret_store" {
  yaml_body = local_file.secret_store.content

  depends_on = [helm_release.esm]

}

# Render ExternalSecret CRD
resource "local_file" "external_secret" {
  filename = "${path.module}/../output/external_secret.yml"
  content = templatefile("${path.module}/../templates/external_secrets.yml", {
    secrets = [
      for k, v in var.secrets : {
        name = k
        path = "${vault_mount.esm.path}/${vault_kv_secret_v2.esm.name}"
      }
    ]
  })
}

# Apply CRD
resource "kubectl_manifest" "external_secret" {
  yaml_body = local_file.external_secret.content

  depends_on = [helm_release.esm]
}
