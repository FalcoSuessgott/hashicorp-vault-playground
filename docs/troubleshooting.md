# Troubleshooting 

## `Error: serviceaccounts "sa-validator" already exists` during bootstrap
```bash
$> make bootstrap
....
│ Error: serviceaccounts "sa-validator" already exists
│ 
│   with module.vault_k8s[0].kubernetes_service_account.service_account,
│   on vault-k8s/terraform/main.tf line 5, in resource "kubernetes_service_account" "service_account":
│    5: resource "kubernetes_service_account" "service_account" {
│ 
╵
make: *** [Makefile:18: bootstrap] Error 1
```

can be solved by running: 

```bash
$> terraform import "module.vault_k8s[0].kubernetes_service_account.service_account" default/sa-validator
```

## `Error: clusterrolebindings.rbac.authorization.k8s.io "vault-token-reviewer" already exists` during bootstrap
```bash
$> make bootstrap
....
╷
│ Error: clusterrolebindings.rbac.authorization.k8s.io "vault-token-reviewer" already exists
│ 
│   with module.vault_k8s[0].kubernetes_cluster_role_binding.role_binding,
│   on vault-k8s/terraform/main.tf line 33, in resource "kubernetes_cluster_role_binding" "role_binding":
│   33: resource "kubernetes_cluster_role_binding" "role_binding" {
│ 
╵
```

can be solved by running: 

```bash
$> terraform import "module.vault_k8s[0].kubernetes_cluster_role_binding.role_binding" vault-token-reviewer
```

## `Error: secrets "sa-validator-token-secret" already exists` during bootstrap
```bash
$> make bootstrap
....
╷
│ Error: secrets "sa-validator-token-secret" already exists
│ 
│   with module.vault_k8s[0].kubernetes_secret.service_account_secret,
│   on vault-k8s/terraform/main.tf line 18, in resource "kubernetes_secret" "service_account_secret":
│   18: resource "kubernetes_secret" "service_account_secret" {
│ 
╵
```

can be solved by running: 

```bash
$> terraform import "module.vault_k8s[0].kubernetes_secret.service_account_secret" default/sa-validator-token-secret
```