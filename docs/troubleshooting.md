# Troubleshooting

## Teardown Environment

```bash
$> make teardown
```

should destroy all terraform managed ressources.

## Clean up
If you wanna clean up your development environment enter:

!!! warning
        Use with Caution, check the Makefile before running!

```bash
$> make cleanup
```

## Remove `minikube` cache

```bash
$> minikube delete --purge
```