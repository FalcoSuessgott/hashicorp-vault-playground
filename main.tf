# Create CA Certificate and Sign Vault Server Certificate + Key
module "tls" {
  source = "./vault-tls/terraform"

  ca_cn   = "HashiCorp Vault Playground CA"
  cert_cn = "Vault"

  ip_sans = ["127.0.0.1"]
  dns_sans = concat(
    ["host.minikube.internal", "host.docker.internal"],
    [for v in range(0, var.vault.nodes) : format("vault-%02d", v + 1)]
  )
}

# Create Vault Raft HA Cluster
module "vault" {
  source = "./vault-server/terraform"

  vault_nodes   = var.vault.nodes
  ip_subnet     = var.vault.ip_subnet
  vault_version = var.vault.version

  initialization = {
    shares    = var.vault.initialization.shares
    threshold = var.vault.initialization.threshold
  }

  depends_on = [module.tls]
}

# Deploy Mysql and Dynamic DB lab
module "database" {
  count = var.databases.enabled ? 1 : 0

  source = "./vault-database/terraform"

  depends_on = [module.vault]
}

# Spin up a minikube k8s cluster
module "minikube" {
  count = var.kubernetes.enabled ? 1 : 0

  source = "./k8s-minikube/terraform"

  depends_on = [module.vault]
}

# Configure Vault K8s Auth Method
module "vault_k8s" {
  count = var.kubernetes.enabled ? 1 : 0

  source = "./vault-k8s/terraform"

  kms_enabled = var.kubernetes.kms

  depends_on = [module.minikube]
}

# Setup Vaults PKI
module "vault_pki" {
  source = "./vault-pki/terraform"

  ca_cert  = module.tls.ca.cert
  priv_key = module.tls.ca.key
}

# Deploy External Secrets Manager
module "esm" {
  count = var.kubernetes.enabled && var.kubernetes.external_secrets_manager ? 1 : 0

  source = "./k8s-external-secrets-operator/terraform"

  ca_cert = module.tls.ca.cert

  depends_on = [module.vault_k8s]
}

# Setup Vault Agent Injector
module "vai" {
  count = var.kubernetes.enabled && var.kubernetes.vault_agent_injector ? 1 : 0

  source = "./k8s-vault-agent-injector/terraform"

  ca_cert = module.tls.ca.cert

  depends_on = [module.vault_k8s]
}

# Setup CSI Secet Driver
module "csi" {
  count = var.kubernetes.enabled && var.kubernetes.csi ? 1 : 0

  source = "./k8s-vault-csi/terraform"

  ca_cert = module.tls.ca.cert

  depends_on = [module.vault_k8s]
}

# Setup Vault Secets Operator
module "vso" {
  count = var.kubernetes.enabled && var.kubernetes.vault_secrets_operator ? 1 : 0

  source = "./k8s-vault-secrets-operator/terraform"

  ca_cert = module.tls.ca.cert

  depends_on = [module.vault_k8s]
}

# Setup Cert manager
module "cm" {
  count = var.kubernetes.enabled && var.kubernetes.cert_manager ? 1 : 0

  source = "./k8s-cert-manager/terraform"

  ca_cert     = module.tls.ca.cert
  minikube_ip = module.minikube[0].minikube_ip

  depends_on = [module.vault_k8s]
}

# Deploy Boundary
module "boundary" {
  count = var.boundary.enabled ? 1 : 0

  source = "./boundary/terraform"

  depends_on = [module.vault_k8s]
}

# Configure Boundary
module "boundary_cfg" {
  count = var.boundary.enabled ? 1 : 0

  source = "./boundary-config/terraform"

  minikube_ip = module.minikube[0].minikube_ip

  depends_on = [module.boundary]
}
