# Quickstart

## Requirements
In order to get this playgroud going, you will need to have:

* terraform
* vault
* jq
* minikube
* docker
* make
* kubectl
* helm

installed on your System.

## Bootstrap
Once you have all requirements installed, you can bootstrap the playground using the following commands:

```bash
$> git clone git@github.com:FalcoSuessgott/hashicorp-vault-playground.git
$> cd hashicorp-vault-playground
$> make bootstrap # equals terraform init && terraform apply
```

## Configuration
You can configure certain settings, by adding the `terraform.tfvars` file.
The following configurations are supported:

```bash
vault = {
  # Number of Vault Nodes in Cluster
  nodes = 3

  # docker network CIDR
  ip_subnet = "172.16.10.0/24"

  # Vault Version
  version = "1.15"

  # baseport where the vault container are exposed to localhost
  base_port = 8000

  # Number of Keys & Shares during Initialization & Unsealing
  initialization = {
    shares    = 5
    threshold = 3
  }
}

# Dyanmic DB Credentials
databases = {
  enabled = true

  # enable mysql db
  mysql = true
}

# Minikube Configuration
kubernetes = {
  # wether to enable minikube deployment
  enabled = true

  # enable external secrets manager
  external_secrets_manager = true

  # enable vault secrets operator
  vault_secrets_operator = true

  # enable secrets using the CSI driver
  csi = true

  # enable cert manager
  cert_manager = true

  # enable vault agent injector
  vault_agent_injector = true
}
```

## Verify
After boostrapping the playground, depending on your configurations, atleast a Vault Raft HA Cluster should have been deployed.

Verify by running:

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

$> vault operator raft list-peers
Node        Address              State       Voter
----        -------              -----       -----
vault-01    172.16.10.10:8201    leader      true
vault-03    172.16.10.12:8201    follower    true
vault-02    172.16.10.11:8201    follower    true
```

## Troubleshooting
If something went wrong, you could use the `docker` CLI for debugging:

```bash
$> docker ps
9d6f7d8ced20   haproxy:latest         "docker-entrypoint.s…"   39 minutes ago   Up 39 minutes   0.0.0.0:443->443/tcp   haproxy
2a560005dc23   hashicorp/vault:latest "docker-entrypoint.s…"   40 minutes ago   Up 40 minutes   0.0.0.0:8001->8200/tcp vault-01
039d3d563e5a   hashicorp/vault:latest "docker-entrypoint.s…"   40 minutes ago   Up 40 minutes   0.0.0.0:8003->8200/tcp vault-03
318eb44b40c1   hashicorp/vault:latest "docker-entrypoint.s…"   40 minutes ago   Up 40 minutes   0.0.0.0:8002->8200/tcp vault-02

$> docker logs vault-01 # see logs of vault-01 container
$> docker exec -it vault-01 sh # get a shell into vault-01 container
```

## Teardown
Once youre done testing, you can destroy all resource, simply by running:

```bash
$> terraform destroy # or make teardown
```
