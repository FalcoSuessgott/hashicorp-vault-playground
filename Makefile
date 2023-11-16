SHELL := /bin/bash

default: help

.PHONY: help
help: ## print targets and their descrptions
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: fmt
fmt: ## fmt
	terraform fmt -recursive -write .

.PHONY: bootstrap
bootstrap: deps ## boostrap cluster
	source  .envrc
	terraform init
	terraform apply -target=module.kubernetes -auto-approve
	terraform apply -auto-approve

.PHONY: teardown
teardown: ## teadown cluster
	terraform destroy -auto-approve

.PHONY: deps
deps: ## verify required deps
	@command -v terraform > /dev/null  || echo "terraform not installed -> https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli"
	@command -v docker > /dev/null || echo "docker not installed -> https://docs.docker.com/engine/install/"
	@command -v minikube > /dev/null || echo "minikube not installed -> https://minikube.sigs.k8s.io/docs/start/"
	@command -v vault > /dev/null || echo "vault not installed -> https://developer.hashicorp.com/vault/docs/install"
	@command -v kubectl > /dev/null || echo "kubectl not installed -> https://kubernetes.io/docs/tasks/tools/install-kubectl-linux"
	@command -v helm > /dev/null || echo "helm not installed -> https://helm.sh/docs/helm/helm_install/"
	@command -v jq > /dev/null || echo "jq not installed -> https://jqlang.github.io/jq/download/"

.PHONY: cleanup
cleanup: ## cleanup
	docker stop $(shell docker ps -aq) || true
	docker rm $(shell docker ps -aq) || true
	docker network rm vault || true

	rm terraform.tfstate || true
	rm terraform.tfstate.backup || true

.PHONY: new-lab
new-lab:  ## creates a new lab directory
	mkdir -p $(name)/terraform
	mkdir -p $(name)/output
	touch $(name)/output/.gitkeep
	mkdir -p $(name)/templates
	mkdir -p $(name)/files
	echo "$(name)" > docs/$(name).md

.PHONY: docs
docs: ## render docs
	firefox http://127.0.0.1:8000/home
	mkdocs serve
