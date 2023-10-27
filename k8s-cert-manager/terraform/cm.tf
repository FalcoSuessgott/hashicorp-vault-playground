# Install CM via Helm
resource "helm_release" "cm" {
  name             = "cm"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  create_namespace = true
  namespace        = "cm"

  values = [file("${path.module}/../files/values.yml")]
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
  filename = "${path.module}/../output/issuer.yml"
  content = templatefile("${path.module}/../templates/issuer.yml", {
    ca_cert = base64encode(var.ca_cert)
  })
}

resource "kubectl_manifest" "vault_issuer" {
  yaml_body = local_file.vault_issuer.content

  depends_on = [helm_release.cm]
}

resource "local_file" "ingress" {
  filename = "${path.module}/../output/ingress.yml"
  content = templatefile("${path.module}/../templates/ingress.yml", {
    minikube_ip = var.minikube_ip
  })
}

resource "kubectl_manifest" "ingress" {
  yaml_body = local_file.ingress.content

  depends_on = [helm_release.cm]
}
