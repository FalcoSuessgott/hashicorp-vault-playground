resource "kubernetes_config_map" "this" {
  count = var.kms_enabled ? 1 : 0

  metadata {
    name      = "trousseau-config"
    namespace = "kube-system"
  }

  data = {
    cfg = templatefile("${path.module}/../templates/trousseau-config.yml.tmpl", {
      token = vault_token.this.client_token
    })
  }

  depends_on = [minikube_cluster.docker]
}

resource "kubectl_manifest" "secret_store" {
  count = var.kms_enabled ? 1 : 0


  yaml_body = file("${path.module}/../files/trousseau.yml")

  depends_on = [kubernetes_config_map.this]
}
