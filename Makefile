default: help

.PHONY: help
help: ## print targets and their descrptions
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: fmt
fmt: ## fmt
	terraform fmt -recursive -write .

.PHONY: bootstrap
bootstrap: ## boostrap cluster
	@command -v terraform || echo "terraform not installed"
	@command -v docker || echo "docker not installed"
	@command -v minikube || echo "minikube not installed"

	terraform init
	terraform apply -target=module.minikube -auto-approve
	terraform apply -auto-approve
	terraform output summary

.PHONY: teardown
teardown: ## teadown cluster
	terraform destroy -auto-approve

.PHONY: cleanup
cleanup: ## cleanup
	docker stop $(shell docker ps -aq) || true
	docker rm $(shell docker ps -aq) || true
	docker network rm vault || true

	rm terraform.tfstate || true
	rm terraform.tfstate.backup || true
