# HAProxy
Vaults UI and API is accessed via HAProxy.
HAProxy is exposed via HTTPS/443 and redirects all incomming traffic to the Vault Leader Node using [Vaults Health Check](https://developer.hashicorp.com/vault/api-docs/system/health).
HAProxy does not terminate the TLS Connection instead of it passes through the connection to the Vault Nodes in order to avoid MITM attacks, as stated by the Vault docs.

## HAProxy Stats & Metrics
You can explore HAProxy Metrics under [http://localhost:8404/stats](http://localhost:8404/stats) and see how the metrics change with every request to Vault.

