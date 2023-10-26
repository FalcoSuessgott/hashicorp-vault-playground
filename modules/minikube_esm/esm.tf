# Install ESM via Helm
resource "helm_release" "esm" {
  name             = "esm"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "esm"
  create_namespace = true

  values = [file("${path.root}/minikube/esm/values.yml")]
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
  filename = "${path.root}/minikube/esm/secret_store.yml"
  content = templatefile("./templates/esm_secret_store.yml.tmpl", {
    name             = var.secret_store_name
    namespace        = helm_release.esm.name
    vault            = "https://host.minikube.internal"
    ca               = base64encode(var.ca_cert)
    vault_auth_mount = "minikube-cluster"
    vault_auth_role  = helm_release.esm.name
    sa_name          = "${helm_release.esm.name}-${helm_release.esm.chart}"
    sa_secret_name   = kubernetes_secret.sa_secret.metadata[0].name
  })
}

# Apply Secret Store CRD
resource "kubectl_manifest" "secret_store" {
  yaml_body = local_file.secret_store.content
}

# Render ExternalSecret CRD
resource "local_file" "external_secret" {
  filename = "${path.root}/minikube/esm/external_secret.yml"
  content = templatefile("${path.root}/templates/esm_external_secrets.yml.tmpl", {
    name              = var.external_secret_name
    namespace         = helm_release.esm.name
    secret_store_name = var.secret_store_name
    secret_name       = var.k8s_secret_name

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
}
