# Vault Agent Injector

## Requirements
For this lab youre going to need `kubectl`, `helm` and `jq` installed.

Also in your `terraform.tfvars`:
```
# terraform.tfvars
minikube = {
  enabled                  = true
  vault_agent_injector     = true
}
```

You then can bootstrap the cluster using `make bootstrap`


## Overview
The following resources will be created:

1. The Vault Agent Injector Helm Chart is going to be installed in the `vai` Namespace.
2. A Kubernetes Auth Role `vai` bound to the `vai` Namespace & Service Account
3. KVv2 Secrets under `vai/secrets` containing 2 Example Secrets
4. A policy (`vai`) that allows reading `/vai/secrets` Secrets
5. A Demo App `kuard` is deployed wiht annotations that trigger the Vault Agent Injector to inject the secrets

## Walkthrough
The Vault Agenjt Injector (vai) is going to be installed in the `vai` namespace using the [Helm Chart](https://github.com/hashicorp/vault-helm).

```bash
$> helm list -n vai
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                         APP VERSION
vai     vai             1               2023-10-05 16:32:06.04091193 +0200 CEST deployed        external-secrets-0.9.5        v0.9.5
```

Additionally, a Vault Kubernetes Auth Role bounded to the Namespace and the vai Service Account has been created:

```bash
# https://localhost/ui/vault/access/minikube-cluster/item/role/vai
$> vault read auth/minikube-cluster/role/vai
Key                                 Value
---                                 -----
alias_name_source                   serviceaccount_uid
bound_service_account_names         [default] # valid SA names
bound_service_account_namespaces    [vai] # valid namespaces
token_bound_cidrs                   []
token_explicit_max_ttl              0s
token_max_ttl                       0s
token_no_default_policy             false
token_num_uses                      0
token_period                        0s
token_policies                      [vai] # attached policies
token_ttl                           1h
token_type                          default
```

Also KVv2 Secrets under `/vai/secrets/` have been created:

```bash
# https://localhost/ui/vault/secrets/vai/kv/secrets/details?version=1
$> vault kv get vai/secrets
== Secret Path ==
vai/data/secrets

======= Metadata =======
Key                Value
---                -----
created_time       2023-10-05T11:58:36.987982616Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

====== Data ======
Key         Value
---         -----
password    P@ssw0rd
username    Admin
```

A corresponding policy `vai` that allows reading the vai secrets has also been crated:

```bash
# https://localhost/ui/vault/policy/acl/vai
$> vault policy read vai
path "vai/" {
  capabilities = ["read", "list"]
}

path "vai/*" {
  capabilities = ["read", "list"]
}
```

A Demo App with annotations telling VAI to inject secrets:

```bash
$> cat k8s-vault-agent-injector/files/kuard.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kuard
  namespace: vai
spec:
  selector:
    matchLabels:
      app: kuard
  replicas: 1
  template:
    metadata:
      annotations:
        # https://developer.hashicorp.com/vault/docs/platform/k8s/injector/annotations
        vault.hashicorp.com/auth-path: "auth/minikube-cluster"
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "vai"
        vault.hashicorp.com/tls-secret: ca-cert
        vault.hashicorp.com/ca-cert: /vault/tls/ca.crt
        vault.hashicorp.com/agent-inject-secret-secrets.txt: 'vai/data/secrets'
        vault.hashicorp.com/agent-inject-template-secrets.txt: |
          {{- with secret "vai/data/secrets" -}}
          { 
            "username": "{{ .Data.data.username }}",
            "password": "{{ .Data.data.password }}"
          }
          {{- end }}
      labels:
        app: kuard
    spec:
      containers:
      - image: gcr.io/kuar-demo/kuard-amd64:1
        imagePullPolicy: Always
        name: kuard
        ports:
        - containerPort: 8080
```

Finally, the Secret containing the KVv2 Secrets from `/vai/secrets/` are injected into the FS of the Container:

```bash
$> kubectl exec -n vai -it $(kubectl get pods -l=app=kuard -n vai --no-headers -o custom-columns=":metadata.name") -- cat /vault/secrets/secrets.txt
username=Admin
password=P@ssw0rd
```
