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

  values = [file("${path.root}/minikube/vso/values.yml")]

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

# Render VaultAuth CRD pointing to Vault
resource "local_file" "vault_auth" {
  filename = "${path.root}/minikube/vso/vault_auth.yml"
  content = templatefile("./templates/vso_vault_auth.yml.tmpl", {
    name             = "vso-vault-auth"
    namespace        = helm_release.vso.name
    vault_auth_mount = vault_kubernetes_auth_backend_role.vso.backend
    vault_auth_role  = helm_release.vso.name
    sa_name          = "default"
  })
}

# Apply VaultAuth CRD
resource "kubectl_manifest" "vault_auth" {
  yaml_body = local_file.vault_auth.content
}

# Render VaultStaticSecret
resource "local_file" "vault_static_secret" {
  filename = "${path.root}/minikube/vso/vault_static_secret.yml"
  content = templatefile("./templates/vso_vault_static_secret.yml.tmpl", {
    name        = "vso-vault-static-secret"
    namespace   = helm_release.vso.name
    mount_path  = vault_mount.vso.path
    secret_path = vault_kv_secret_v2.vso.name
    secret_name = "vso-secret"
    vault_auth  = "vso-vault-auth"
  })
}

# Apply Secret Store CRD
resource "kubectl_manifest" "vault_static_secret" {
  yaml_body = local_file.vault_static_secret.content
}
