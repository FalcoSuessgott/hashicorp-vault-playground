# Create CA Certificate and Sign Vault Server Certificate + Key
module "tls" {
  source = "./vault-tls/terraform"

  ca_cn   = "HashiCorp Vault Playground CA"
  cert_cn = "Vault"

  ip_sans = ["127.0.0.1"]
  dns_sans = concat(
    ["host.minikube.internal"],
    [for v in range(0, var.vault.nodes) : format("vault-%02d", v + 1)]
  )
}

# Create Vault Raft HA Cluster
module "vault" {
  source = "./vault-server/terraform"

  vault_nodes   = 3
  ip_subnet     = var.vault.ip_subnet
  vault_version = var.vault.version

  initialization = {
    shares    = var.vault.initialization.shares
    threshold = var.vault.initialization.threshold
  }

  depends_on = [module.tls]
}

# Spin up a K8s Cluster
module "minikube" {
  count = var.minikube.enabled ? 1 : 0

  source = "./k8s-minikube/terraform"

  depends_on = [module.vault]
}

# Configure Vault K8s Auth Method
module "vault_k8s" {
  count = var.minikube.enabled ? 1 : 0

  source = "./vault-k8s/terraform"

  depends_on = [module.minikube]
}

module "vault_pki" {
  source = "./vault-pki/terraform"

  ca_cert  = module.tls.ca.cert
  priv_key = module.tls.ca.key
}

# Deploy External Secrets Manager
module "esm" {
  count = var.minikube.enabled && var.minikube.external_secrets_manager ? 1 : 0

  source = "./k8s-external-secrets-operator/terraform"

  ca_cert = module.tls.ca.cert

  depends_on = [module.vault_k8s]
}

module "vai" {
  count = var.minikube.enabled && var.minikube.vault_agent_injector ? 1 : 0

  source = "./k8s-vault-agent-injector/terraform"

  ca_cert = module.tls.ca.cert

  depends_on = [module.vault_k8s]
}

module "vso" {
  count = var.minikube.enabled && var.minikube.vault_secrets_operator ? 1 : 0

  source = "./k8s-vault-secrets-operator/terraform"

  ca_cert = module.tls.ca.cert

  depends_on = [module.vault_k8s]
}

module "cm" {
  count = var.minikube.enabled && var.minikube.cert_manager ? 1 : 0

  source = "./k8s-cert-manager/terraform"

  ca_cert     = module.tls.ca.cert
  minikube_ip = module.minikube[0].minikube_ip

  depends_on = [module.vault_k8s]
}

module "monitoring" {
  source = "./k8s-monitoring/terraform"

  ca_cert     = module.tls.ca.cert
  minikube_ip = module.minikube[0].minikube_ip

  depends_on = [module.vault_k8s]
}
