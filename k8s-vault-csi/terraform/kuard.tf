resource "kubectl_manifest" "kuard" {
  yaml_body = file("${path.module}/../files/kuard.yml")

  depends_on = [vault_kubernetes_auth_backend_role.csi]
}
