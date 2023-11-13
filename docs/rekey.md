# Rekeying Vault

You can generate a new unseal keys using the following snippet:

```bash
# start rekey process with 3 shares and 2 threshold
$> vault operator rekey -init -key-shares=3 -key-threshold=2
WARNING! If you lose the keys after they are returned, there is no recovery.
Consider canceling this operation and re-initializing with the -pgp-keys flag
to protect the returned unseal keys along with -backup to allow recovery of
the encrypted keys in case of emergency. You can delete the stored keys later
using the -delete flag.

Key                      Value
---                      -----
Nonce                    91365630-524b-dfce-cf2b-ed777db412d8
Started                  true
Rekey Progress           0/3
New Shares               3
New Threshold            2
Verification Required    false

# because there is no tty, we have to speciy a nonce, and the unseal key via STDIN
$> NONCE=91365630-524b-dfce-cf2b-ed777db412d8; for v in $(tf output -json unseal_keys | jq -r '.[]'); do VAULT_ADDR="https://127.0.0.1:8001" echo $v | vault operator rekey -nonce=$NONCE -; done
Key                      Value
---                      -----
Nonce                    91365630-524b-dfce-cf2b-ed777db412d8
Started                  true
Rekey Progress           1/3
New Shares               3
New Threshold            2
Verification Required    false
Key                      Value
---                      -----
Nonce                    91365630-524b-dfce-cf2b-ed777db412d8
Started                  true
Rekey Progress           2/3
New Shares               3
New Threshold            2
Verification Required    false

Key 1: /jkk9//ZEqDoEqXsf3NDRu4R+gIF1tZ9WdN5QrSt0odX # unseal key 1
Key 2: HroWSiYp5EySPA2rz94f4wg3fCE7GiMTaIIIWmrtsZeT # unseal key 2
Key 3: LVse36NDsANEEeAW2hJFjgW7vIxP52hBf1hgoi2SY87P # unseal key 3

Operation nonce: 91365630-524b-dfce-cf2b-ed777db412d8

Vault unseal keys rekeyed with 3 key shares and a key threshold of 2. Please
securely distribute the key shares printed above. When Vault is re-sealed,
restarted, or stopped, you must supply at least 2 of these keys to unseal it
before it can start servicing requests.
```
