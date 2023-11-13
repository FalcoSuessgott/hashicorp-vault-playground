# HAProxy
Vaults UI and API is accessed via HAProxy.
HAProxy is exposed via HTTPS/443 and redirects all incomming traffic to the Vault Leader Node using [Vaults Health Check](https://developer.hashicorp.com/vault/api-docs/system/health).
HAProxy does not terminate the TLS Connection instead of it passes through the connection to the Vault Nodes in order to avoid MITM attacks, as stated by the Vault docs.

## Configuration
See the final HAProxy Configuration:

```bash
$> docker exec -it haproxy sh -c "cat /usr/local/etc/haproxy/haproxy.cfg"
Alias tip: dke -it haproxy sh -c "cat /usr/local/etc/haproxy/haproxy.cfg"
global
   log stdout format raw local0 info
   maxconn 3000

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

# enable haproxy metrics
frontend stats
    mode http
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 10s
    stats admin if LOCALHOST

# expose vault api via 443 & 80
frontend vault
      mode tcp
      log global
      timeout client 30000
      bind *:80
      bind *:443
      description Vault over https
      default_backend vault_https
      option tcplog

# redirect requests from vault frontend to vault server nodes via TCP
backend vault_https
     mode tcp
     timeout check 5000
     timeout server 30000
     timeout connect 5000
     # enable Vault Health Check
     option httpchk GET /v1/sys/health
     http-check expect status 200

     # do not terminate TLS to avoid MITM
     server vault-01 vault-01:8200 check check-ssl verify none
     server vault-02 vault-02:8200 check check-ssl verify none
     server vault-03 vault-03:8200 check check-ssl verify none
```

## HAProxy Stats & Metrics
You can explore HAProxy Metrics under [http://localhost:8404/stats](http://localhost:8404/stats) and see how the metrics change with every request to Vault.
