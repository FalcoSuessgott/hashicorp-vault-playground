# Minikube
A local Minikube cluster can be created during bootstrapping if enabled:

```hcl
# terraform.tfvars
minikube = {
  enabled = true
}
```

## Access
After bootstrapping you should be able access it using `kubectl`:

```bash
$> kubectl get pods -A
NAMESPACE              NAME                                                             READY   STATUS              RESTARTS      AGE
kube-system            coredns-787d4945fb-8k882                                         1/1     Running             0             29s
kube-system            etcd-vault-playground                                            1/1     Running             0             42s
kube-system            kube-apiserver-vault-playground                                  1/1     Running             0             43s
kube-system            kube-controller-manager-vault-playground                         1/1     Running             0             42s
kube-system            kube-proxy-5jkqv                                                 1/1     Running             0             29s
kube-system            kube-scheduler-vault-playground                                  1/1     Running             0             43s
kube-system            storage-provisioner                                              1/1     Running             1 (28s ago)   40s
kubernetes-dashboard   dashboard-metrics-scraper-5c6664855-vff6h                        1/1     Running             0             29s
kubernetes-dashboard   kubernetes-dashboard-55c4cbbc7c-7rv8w                            1/1     Running             0             29s
```

As well as the Kubernetes Dashboard:

```bash
$> minikube profile vault-playground
$> minikube dashboard # opens Dashbord in browser
$> minikube dashboard --url # print Dashboard URL
```

## Vault Integration
The Vault and the Minikube Cluster is configured for the Kubernetes Authentication:

A Kubernetes Auth Method has been mounted inat `minikube-cluster`:

```bash
# https://localhost/ui/vault/access/minikube-cluster/item/role
$> vault read auth/minikube-cluster/config
Key                       Value
---                       -----
disable_iss_validation    false
disable_local_ca_jwt      false
issuer                    n/a
kubernetes_ca_cert        ""
kubernetes_host           https://host.docker.internal:8443
pem_keys                  []
```

A Service Account `sa-validator` has been created, that can validate other SAs due to a ClusterRoleBinding:

```bash
$> kubectl get sa sa-validator
NAME           SECRETS   AGE
sa-validator   1         6m54s
$> kubectl get clusterrolebinding vault-token-reviewer
NAME                   ROLE                                AGE
vault-token-reviewer   ClusterRole/system:auth-delegator   6m1s
```
