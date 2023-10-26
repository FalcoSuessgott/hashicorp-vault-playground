# Create CA Certificate and Sign Vault Server Certificate + Key
module "tls" {
  source = "./modules/tls"

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
  source = "./modules/vault"

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

  source = "./modules/minikube"

  depends_on = [module.vault]
}

# Configure Vault K8s Auth Method
module "vault_k8s" {
  count = var.minikube.enabled ? 1 : 0

  source = "./modules/vault_k8s"

  depends_on = [module.minikube]
}

module "vault_pki" {
  source = "./modules/vault_pki"

  ca_cert  = module.tls.ca_cert
  priv_key = module.tls.ca_key
}

# Deploy External Secrets Manager
module "esm" {
  count = var.minikube.enabled && var.minikube.external_secrets_manager ? 1 : 0

  source = "./modules/minikube_esm"

  ca_cert = module.tls.ca_cert

  depends_on = [module.vault_k8s]
}

# Deploy Vault Secrets Operator
module "vso" {
  count = var.minikube.enabled && var.minikube.vault_secrets_operator ? 1 : 0

  source = "./modules/minikube_vso"

  ca_cert = module.tls.ca_cert

  depends_on = [module.vault_k8s]
}

# Deploy Cert Manager
module "cm" {
  count = var.minikube.enabled && var.minikube.cert_manager ? 1 : 0

  source = "./modules/minikube_cm"

  ca_cert = module.tls.ca_cert

  depends_on = [module.vault_k8s]
}
