# Generate Root
Using the unseal-keys we can regenarate a root token

## Revoke Root

```bash
$> vault token revoke $VAULT_TOKEN
Success! Revoked token (if it existed)
$> vault kv get esm/secrets
Error making API request.

URL: GET https://127.0.0.1/v1/sys/internal/ui/mounts/esm/secrets
Code: 403. Errors:
```

## Generate Root

```bash
# init generate-root process
$> vault operator generate-root -init
A One-Time-Password has been generated for you and is shown in the OTP field.
You will need this value to decode the resulting root token, so keep it safe.
Nonce         b024b19a-723d-3ec1-1d26-cf30c680d068 # important
Started       true
Progress      0/3
Complete      false
OTP           MQHg64qQAHXlOWKJHJFkXBIIisG7          # important
OTP Length    28

# because there is no tty, we have to speciy a nonce, and the unseal key via STDIN
$> NONCE=b024b19a-723d-3ec1-1d26-cf30c680d068; for v in $(tf output -json unseal_keys | jq -r '.[]'); do VAULT_ADDR="https://127.0.0.1:8001" echo $v | vault operator generate-root -nonce=$NONCE -; done
Nonce       b024b19a-723d-3ec1-1d26-cf30c680d068
Started     true
Progress    1/3
Complete    false
Nonce       b024b19a-723d-3ec1-1d26-cf30c680d068
Started     true
Progress    2/3
Complete    false
Nonce            b024b19a-723d-3ec1-1d26-cf30c680d068
Started          true
Progress         3/3
Complete         true
Encoded Token    JSc7SQd7KyV5GwsLBT4oKwcQIDsvKjEgEBsKfw # important

# decode token using the OTP
$> vault operator generate-root -decode JSc7SQd7KyV5GwsLBT4oKwcQIDsvKjEgEBsKfw -otp MQHg64qQAHXlOWKJHJFkXBIIisG7
hvs.1OZt8SSgJicaOZfPwhxiyhMH
```

## Verify


```bash
$> VAULT_TOKEN=hvs.1OZt8SSgJicaOZfPwhxiyhMH vault token lookup
Key                 Value
---                 -----
accessor            WyUkIqrs4YOehRpv6d7Pn0Oe
creation_time       1699878520
creation_ttl        0s
display_name        root
entity_id           n/a
expire_time         <nil>
explicit_max_ttl    0s
id                  hvs.1OZt8SSgJicaOZfPwhxiyhMH
meta                <nil>
num_uses            0
orphan              true
path                auth/token/root
policies            [root] # root token
ttl                 0s
type                service
```

# Resources
* [https://developer.hashicorp.com/vault/tutorials/operations/generate-root](https://developer.hashicorp.com/vault/tutorials/operations/generate-root)
