CLUSTER_NAME := gitops-platform
KIND_CONFIG  := kind/cluster.yaml

.PHONY: help cluster-up cluster-down cluster-status tf-fmt tf-validate

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# ---------------------------------------------------------------------------
# Local cluster (kind)
# ---------------------------------------------------------------------------

cluster-up: ## Create the local kind cluster
	kind create cluster --config $(KIND_CONFIG)
	kubectl cluster-info --context kind-$(CLUSTER_NAME)

cluster-down: ## Delete the local kind cluster
	kind delete cluster --name $(CLUSTER_NAME)

cluster-status: ## Show nodes and kube-system pods
	kubectl --context kind-$(CLUSTER_NAME) get nodes -o wide
	kubectl --context kind-$(CLUSTER_NAME) -n kube-system get pods

# ---------------------------------------------------------------------------
# Terraform (EKS variant)
# ---------------------------------------------------------------------------

tf-fmt: ## terraform fmt (check)
	terraform -chdir=terraform fmt -check -recursive

tf-validate: ## terraform init + validate
	terraform -chdir=terraform init -backend=false -input=false
	terraform -chdir=terraform validate
