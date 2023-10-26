# Cert-Manager

## Requirements
For this lab youre going to need `kubectl`, `helm` and `jq` installed.

Also in your `terraform.tfvars`:
```
# terraform.tfvars
minikube = {
  enabled = true
  cert_manager = true
}
```

You then can bootstrap the cluster using `make bootstrap`


## Overview
The following resources will be created:

1. The Cert Manager Helm Chart is going to be installed in the `cm` Namespace.
2. A Kubernetes Auth Role `cm` bound to the `cm` Namespace & Service Account
3. PKI Engine under `cert-manager` is configured and role `nip-io` has been created 
4. A policy (`cm`) that allows signing and issuing certificates for the `nip-io` PKI Role is created. (Read more about [nip.io](https://nip.io/))
5. An Issuer `vault-issuer` is created for authenticating to Vault
6. An Ingress resource `ingress` is created requesting a Certificate from Vaults PKI
7. A Demo Application `kuard` and its respective Service is created

## Walkthrough
The Cert Manager (CM) is going to be installed in the `cm` namespace using the [Helm Chart](https://github.com/cert-manager/cert-manager/tree/master/deploy/charts/cert-manager):

```bash
$>  helm list -n cm 
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
cm      cm              1               2023-10-27 09:56:20.72302046 +0200 CEST deployed        cert-manager-v1.13.1    v1.13.1 
```

Additionally, a Vault Kubernetes Auth Role bounded to the Namespace and the ESM Service Account has been created:

```bash
# https://localhost/ui/vault/access/minikube-cluster/item/role/cm
$> vault read auth/minikube-cluster/role/cm 
Key                                 Value
---                                 -----
alias_name_source                   serviceaccount_uid
bound_service_account_names         [vault-issuer]
bound_service_account_namespaces    [cm]
token_bound_cidrs                   []
token_explicit_max_ttl              0s
token_max_ttl                       0s
token_no_default_policy             false
token_num_uses                      0
token_period                        0s
token_policies                      [cm]
token_ttl                           1h
token_type                          default
```

A CSR for the intermediate CA has been created and signed using the CA Cert key:

```bash
# https://localhost/ui/vault/secrets/cert-manager-intermediate/pki/issuers
$>  vault list cert-manager-intermediate/issuers
Keys
----
f3996671-fddd-0c89-1e5f-78771e40151a
```

a PKI role `nip-io` has been created, allowing issuing of certs for `nip.io` subdomain:

```bash
# https://localhost/ui/vault/secrets/cert-manager-intermediate/pki/issuers
$> vault read cert-manager-intermediate/roles/nip-io    
Key                                   Value
---                                   -----
allow_any_name                        false
allow_bare_domains                    false
allow_glob_domains                    false
allow_ip_sans                         true
allow_localhost                       true
allow_subdomains                      true
allow_token_displayname               false
allow_wildcard_certificates           true
allowed_domains                       [nip.io]
...
```

A corresponding policy `cm` that allows reading issuing and singing certs has been created:

```bash
# https://localhost/ui/vault/policy/acl/cm
$> vault policy read cm
path "intermediate-ca" { 
  capabilities = ["read", "list"] 
}

path "intermediate-ca/sign/nip-io" { 
  capabilities = ["create", "update"] 
}

path "intermediate-ca/issue/nip-io" { 
  capabilities = ["create"] 
}
```

We deploy `kuard` as a Demo App aswell as a corresponding service:

```bash
$>cat minikube/cm/kuard.yml                                                              
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kuard
  namespace: cm
spec:
  selector:
    matchLabels:
      app: kuard
  replicas: 1
  template:
    metadata:
      labels:
        app: kuard
    spec:
      containers:
      - image: gcr.io/kuar-demo/kuard-amd64:1
        imagePullPolicy: Always
        name: kuard
        ports:
        - containerPort: 8080
$> cat minikube/cm/kuard_svc.yml 
---
apiVersion: v1
kind: Service
metadata:
  name: kuard
  namespace: cm
spec:
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
  selector:
    app: kuard
```

A Issuer has been created authenticating to Vault and the PKI Engine:

```bash
$> cat minikube/cm/issuer.yml   
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: vault-issuer
  namespace: cm
spec:
  vault:
    path: cert-manager-intermediate/sign/nip-io
    server: https://host.minikube.internal
    caBundle: ""
    auth:
      kubernetes:
        role: cm
        mountPath: /v1/auth/minikube-cluster
        serviceAccountRef:
          name: vault-issuer
```

An Ingress has been created, pointing to our Demo App and requesting a Certificate:

```bash
$> cat minikube/cm/ingress.yml 
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/issuer: vault-issuer
  name: ingress
  namespace: cm
spec:
  rules:
  - host: 192.168.49.2.nip.io
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: kuard
            port:
              number: 80
  tls:
  - hosts:
    - 192.168.49.2.nip.io
    secretName: kuard-cert
```

The certificate was requested, signed and issued successfully and is stored as a kubernetes secret:

```bash
$> kubectl describe secret kuard-cert -n cm   
Name:         kuard-cert
Namespace:    cm
Labels:       controller.cert-manager.io/fao=true
Annotations:  cert-manager.io/alt-names: 192.168.49.2.nip.io
              cert-manager.io/certificate-name: kuard-cert
              cert-manager.io/common-name: 
              cert-manager.io/ip-sans: 
              cert-manager.io/issuer-group: cert-manager.io
              cert-manager.io/issuer-kind: Issuer
              cert-manager.io/issuer-name: vault-issuer
              cert-manager.io/uri-sans: 

Type:  kubernetes.io/tls

Data
====
tls.key:  1675 bytes
ca.crt:   1107 bytes
tls.crt:  2392 bytes
```

You can see that the connection to `kuard` is now secured and verified using the CA certificate:

```bash
$> minikube profile vault-playground
$> curl "https://$(minikube ip).nip.io"
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
$> curl "https://$(minikube ip).nip.io" --cacert vault/ca.crt
<!doctype html>
...
```