# TLS
An CA Certificate as well as a TLS Certificate for Vault has been created and configured under Vault:

You cvan check that the Vault Certificate has been issued from our CA:

```bash
$> openssl verify -CAfile vault-tls/output/ca.crt vault-tls/output/vault.crt
vault-tls/output/vault.crt: OK
```

The Vault Nodes DNS Names have been added as SANS to the Vault Cert:
```bash
$> openssl x509 -noout -ext subjectAltName -in vault-tls/output/vault.crt
X509v3 Subject Alternative Name:
    DNS:host.minikube.internal, DNS:vault-01, DNS:vault-02, DNS:vault-03, IP Address:127.0.0.1
```

You can see how the connection without the CA-Cert is considered insecure:

```bash
$> curl https://127.0.0.1
curl: (60) SSL certificate problem: self-signed certificate in certificate chain
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

But when you specifiy the CA-Cert Vaults Certificate can be verified:

```bash
$> curl https://127.0.0.1 --cacert $VAULT_CAPATH
<a href="/ui/">Temporary Redirect</a>.
```
