# External Secrets Manager

## Requirements
For this lab youre going to need `kubectl`, `helm` and `jq` installed.

Also in your `terraform.tfvars`:
```
# terraform.tfvars
minikube = {
  enabled                  = true
  external_secrets_manager = true
}
```

You then can bootstrap the cluster using `make bootstrap`


## Overview
The following resources will be created:

1. The External Secrets Manager Helm Chart is going to be installed in the `esm` Namespace.
2. A Kubernetes Auth Role `esm` bound to the `esm` Namespace & Service Account
3. KVv2 Secrets under `esm/secrets` containing 2 Example Secrets
4. A policy (`esm`) that allows reading `/esm/secrets` Secrets
5. A CRD `SecretStore` pointing to the Vault Server
6. A CRD `ExternalSecret` that creates a Kubernetes Secrets synchronized with the values stored in `/esm/secrets`

## Walkthrough
The External Secrets Manager (ESM) is going to be installed in the `esm` namespace using the [Helm Chart](https://github.com/external-secrets/external-secrets/tree/main/deploy/charts/external-secrets).

```bash
$> helm list -n esm
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                         APP VERSION
esm     esm             1               2023-10-05 16:32:06.04091193 +0200 CEST deployed        external-secrets-0.9.5        v0.9.5
```

Additionally, a Vault Kubernetes Auth Role bounded to the Namespace and the ESM Service Account has been created:

```bash
# https://localhost/ui/vault/access/minikube-cluster/item/role/esm
$> vault read auth/minikube-cluster/role/esm
Key                                 Value
---                                 -----
alias_name_source                   serviceaccount_uid
bound_service_account_names         [esm-external-secrets] # valid SA names
bound_service_account_namespaces    [esm] # valid namespaces
token_bound_cidrs                   []
token_explicit_max_ttl              0s
token_max_ttl                       0s
token_no_default_policy             false
token_num_uses                      0
token_period                        0s
token_policies                      [esm] # attached policies
token_ttl                           1h
token_type                          default
```

Also KVv2 Secrets under `/esm/secrets/` have been created:

```bash
# https://localhost/ui/vault/secrets/esm/kv/secrets/details?version=1
$> vault kv get esm/secrets
== Secret Path ==
esm/data/secrets

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

A corresponding policy `esm` that allows reading the esm secrets has also been crated:

```bash
# https://localhost/ui/vault/policy/acl/esm
$> vault policy read esm
path "esm/" {
  capabilities = ["read", "list"]
}

path "esm/*" {
  capabilities = ["read", "list"]
}
```

A CRD `SecretStore` has been created:

```bash
$> cat k8s-external-secrets-manager/output/secret_store.yml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: secret-store
  namespace: esm
spec:
  provider:
    vault:
      server: https://host.minikube.internal
      caBundle: ""
      auth:
        kubernetes:
          mountPath: minikube-cluster
          role: esm
          serviceAccountRef:
            name: esm-external-secrets
          secretRef:
            name: esm-external-secrets-token-jgwbf
            key: token
  retrySettings:
    maxRetries: 5
    retryInterval: 10s
```

And a CRD `ExternalSecret` has been created:

```bash
$> cat k8s-external-secrets-manager/output/external_secret.yml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: external-secret
  namespace: esm
spec:
  secretStoreRef:
    name: secret-store
    kind: SecretStore
  refreshInterval: "1h"
  target:
    name: esm-secret

  data:
    - secretKey: password
      remoteRef:
        key: esm/secrets
        property: password
    - secretKey: username
      remoteRef:
        key: esm/secrets
        property: username
```

Finally, a Kubernetes Secret containing the KVv2 Secrets from `/esm/secrets/` has been created:

```bash
$> kubectl get secret -n esm esm-secret -o json | jq '.data | map_values(@base64d)'
{
  "password": "P@ssw0rd",
  "username": "Admin"
}
```


## Addtional Resources
* [https://github.com/external-secrets/external-secrets](https://github.com/external-secrets/external-secrets)
* [https://external-secrets.io/main/](https://external-secrets.io/main/)
* [https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2)
