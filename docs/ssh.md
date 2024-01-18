# SSH secrets engine

![img](assets/shh_sign.png)
> https://www.hashicorp.com/blog/managing-ssh-access-at-scale-with-hashicorp-vault


The idea of the ssh secret engine is to supplement the classic ssh public key authentication with a signing workflow.

This means that public keys are no longer entered in the authorized keys files on individual hosts. Instead, all hosts trust the vault ssh ca and therefore keys signed by it. The contexts in which the signed key are valid is specified in the signature.

To log on to a server, not only the private key but also the corresponding public key signed by the vault ca must be provided.

The numbers in the diagram represent the following steps:

- User creates a personal SSH key pair.
- User authenticates to Vault with their Identity Provider (IDP) credentials.
- Once authenticated, the user sends their SSH public key to Vault for signing.
- Vault signs the SSH key and return the SSH certificate to the user.
- User initiates SSH connection using the SSH certificate.
- Host verifies the client SSH certificate is signed by the trusted SSH CA and allows connection.

[HashiCorp Blog](https://www.hashicorp.com/blog/managing-ssh-access-at-scale-with-hashicorp-vault)


## Requirements
You can enable this lab by setting:

```yaml
# terraform.tfvars
ssh = {
  enabled = true
}
```

You then can bootstrap the cluster using `make bootstrap`

## Overview
The following resources will be created:

1. A Ubuntu Container will be deployed
2. The ssh secret engine will be enabled
3. A ssh signing ca will be created
4. A ssh secret backend role that will allow you to login as the ubuntu user

## Walkthrough

The SSH signing ca has been configured under the `ssh-client-signer` path.

```bash
$ vault secrets list
Path                          Type         Accessor              Description
----                          ----         --------              -----------
ssh-client-signer/            ssh          ssh_002866eb          n/a

$ vault read ssh-client-signer/config/ca
Key           Value
---           -----
public_key    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjcpfjEV7fqCj6I14a6oGrfy6M9Fgi5ZQj7brbocNXG4w4GkZkrO5g93fec+5vcn6eoJYG4n==
```

A ssh signer role has been created.

```bash
$vault read ssh-client-signer/roles/ubuntu
Key                            Value
---                            -----
algorithm_signer               default
allow_bare_domains             false
allow_host_certificates        false
allow_subdomains               false
allow_user_certificates        true
allow_user_key_ids             false
allowed_critical_options       n/a
allowed_domains                n/a
allowed_domains_template       false
allowed_extensions             n/a
allowed_user_key_lengths       map[]
allowed_users                  ubuntu
allowed_users_template         false
default_critical_options       map[]
default_extensions             map[permit-pty:]
default_extensions_template    false
default_user                   ubuntu
default_user_template          false
key_id_format                  n/a
key_type                       ca
max_ttl                        0s
not_before_duration            30s
ttl 
```

To log in to the ubuntu container you need to sign you public key.

```bash
$ vault write -field=signed_key ssh-client-signer/sign/ubuntu public_key=@$HOME/.ssh/id_rsa.pub >| signed-cert.pub
```

Query the ip of the ubuntu container and use the signed public key and your private key to connect.

```bash
export UBUNTU_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ubuntu

ssh -i signed-cert.pub -i ~/.ssh/id_rsa ubuntu@$UBUNTU_IP
```

