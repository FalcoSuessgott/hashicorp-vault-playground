# Seal & Unsealing
Vault is automatically unsealed during bootstrapping.

## Seal
You can seal the vault cluster:

```bash
# https://localhost/ui/vault/settings/seal
$> vault operator seal
Success! Vault is sealed.
$> vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true # sealed
Total Shares       5
Threshold          3
Unseal Progress    0/3
Unseal Nonce       n/a
Version            1.15.0
Build Date         2023-09-22T16:53:10Z
Storage Type       raft
HA Enabled         true
```

## Unseal
Unseal the Vault using unseal keys:
```bash
# avoid LB since there is no leader currently
$> for v in $(tf output -json unseal_keys | jq -r '.[]'); do VAULT_ADDR="https://127.0.0.1:8001" vault operator unseal $v; done
$> vault status
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.15.0
Build Date              2023-09-22T16:53:10Z
Storage Type            raft
Cluster Name            vault-cluster-72d01233
Cluster ID              2fe3e6bc-a386-a5d9-c151-da34c91e91c9
HA Enabled              true
HA Cluster              https://172.16.10.12:8201
HA Mode                 active
Active Since            2023-11-10T14:15:08.957733343Z
Raft Committed Index    110
Raft Applied Index      110
```
