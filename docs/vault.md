# Vault
After a succesfull bootstrapping, you should be able to log into your local Vault HA Cluster by opening [https://127.0.0.1](https://127.0.0.1) in your browser.
Since the CA File is not trusted by your System you the browser will mark the page is insecure, which is fine for now.

## TLS
An CA Certificate as well as a TLS Certificate for Vault has been created and configured under Vault.

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

## CLI Authentication
A file `.vault_token` containing Vaults Root-Token has been created. This allos you to login to the Vault Cluster
Your shell can authenticate to the Vault Cluster using environment vars.

Simply source [`.envrc`](https://github.com/FalcoSuessgott/hashicorp-vault-playground/blob/main/.envrc) and run `vault status`

```bash
$> source .envrc

$> vault status
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.12.2
Build Date              2022-11-23T12:53:46Z
Storage Type            raft
Cluster Name            vault-cluster-18051650
Cluster ID              3ae2ae33-ffb0-630e-c73c-5cd8755f81d4
HA Enabled              true
HA Cluster              https://172.16.10.10:8201
HA Mode                 active
Active Since            2023-10-06T07:55:40.738642219Z
Raft Committed Index    217
Raft Applied Index      217
```

## Vault HA Cluster Members
Verify the Raft HA Cluster members
```bash
$> vault operator raft list-peers
Node        Address              State       Voter
----        -------              -----       -----
vault-01    172.16.10.10:8201    leader      true
vault-03    172.16.10.12:8201    follower    true
vault-02    172.16.10.11:8201    follower    true
```
