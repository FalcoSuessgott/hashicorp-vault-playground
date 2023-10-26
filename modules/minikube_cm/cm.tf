# Install CM via Helm
resource "helm_release" "cm" {
  name             = "cm"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  create_namespace = true
  namespace        = "cm"

  values = [file("${path.root}/minikube/cm/values.yml")]
}

# https://cert-manager.io/docs/configuration/vault/#secretless-authentication-with-a-service-account
resource "kubernetes_role" "vault_issuer" {
  metadata {
    name      = "vault-issuer"
    namespace = helm_release.cm.namespace
  }

  rule {
    api_groups     = [""]
    resources      = ["serviceaccounts/token"]
    resource_names = ["vault-issuer"]
    verbs          = ["create"]
  }
}
resource "kubernetes_service_account" "vault_issuer" {
  metadata {
    name      = "vault-issuer"
    namespace = helm_release.cm.namespace
  }
}

resource "kubernetes_role_binding_v1" "rb" {
  metadata {
    name      = "vault-issuer"
    namespace = helm_release.cm.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.vault_issuer.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cm-cert-manager"
    namespace = helm_release.cm.namespace
  }
}

resource "local_file" "vault_issuer" {
  filename = "${path.root}/minikube/cm/issuer.yml"
  content = templatefile("./templates/cm_issuer.yml.tmpl", {
    name             = "vault-issuer"
    vault_server     = "https://host.minikube.internal"
    namespace        = helm_release.cm.namespace
    ca_cert          = base64encode(var.ca_cert)
    vault_auth_mount = vault_kubernetes_auth_backend_role.cm.backend
    vault_auth_role  = vault_kubernetes_auth_backend_role.cm.role_name
    sa_name          = "vault-issuer"
  })
}

resource "kubectl_manifest" "vault_issuer" {
  yaml_body = local_file.vault_issuer.content
}

resource "local_file" "ingress" {
  filename = "${path.root}/minikube/cm/ingress.yml"
  content = templatefile("./templates/cm_ingress.yml.tmpl", {
  })
}

resource "kubectl_manifest" "ingress" {
  yaml_body = local_file.ingress.content

  depends_on = [helm_release.cm]
}
