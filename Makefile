CLUSTER_NAME    := gitops-platform
KIND_CONFIG     := kind/cluster.yaml
KCTX            := kind-$(CLUSTER_NAME)
ARGOCD_NS       := argocd
ARGOCD_CHART_V  := 7.6.12
ARGOCD_VALUES   := platform/argocd/values.yaml
ROOT_APP        := platform/argocd/bootstrap/root-app.yaml
PROJECTS        := platform/argocd/projects

.PHONY: help \
        cluster-up cluster-down cluster-status \
        tf-fmt tf-validate \
        bootstrap argocd-install argocd-projects argocd-root \
        argocd-ui argocd-password argocd-status \
        teardown

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# ---------------------------------------------------------------------------
# Local cluster (kind)
# ---------------------------------------------------------------------------

cluster-up: ## Create the local kind cluster
	kind create cluster --config $(KIND_CONFIG)
	kubectl cluster-info --context $(KCTX)

cluster-down: ## Delete the local kind cluster
	kind delete cluster --name $(CLUSTER_NAME)

cluster-status: ## Show nodes and kube-system pods
	kubectl --context $(KCTX) get nodes -o wide
	kubectl --context $(KCTX) -n kube-system get pods

# ---------------------------------------------------------------------------
# Terraform (EKS variant)
# ---------------------------------------------------------------------------

tf-fmt: ## terraform fmt (check)
	terraform -chdir=terraform fmt -check -recursive

tf-validate: ## terraform init + validate
	terraform -chdir=terraform init -backend=false -input=false
	terraform -chdir=terraform validate

# ---------------------------------------------------------------------------
# ArgoCD bootstrap
# ---------------------------------------------------------------------------

bootstrap: argocd-install argocd-projects argocd-root argocd-status ## One-shot: install ArgoCD + apply root app-of-apps

argocd-install: ## Install ArgoCD via Helm (idempotent)
	helm repo add argo https://argoproj.github.io/argo-helm >/dev/null 2>&1 || true
	helm repo update argo
	helm upgrade --install argocd argo/argo-cd \
	  --namespace $(ARGOCD_NS) --create-namespace \
	  --version $(ARGOCD_CHART_V) \
	  --values $(ARGOCD_VALUES) \
	  --kube-context $(KCTX) \
	  --wait

argocd-projects: ## Apply AppProjects (platform, apps)
	kubectl --context $(KCTX) apply -f $(PROJECTS)/

argocd-root: ## Apply the root app-of-apps Application
	kubectl --context $(KCTX) apply -f $(ROOT_APP)

argocd-ui: ## Port-forward the ArgoCD UI to http://localhost:8080
	@echo "Open http://localhost:8080 — user: admin"
	kubectl --context $(KCTX) -n $(ARGOCD_NS) port-forward svc/argocd-server 8080:80

argocd-password: ## Print the initial admin password
	@kubectl --context $(KCTX) -n $(ARGOCD_NS) get secret argocd-initial-admin-secret \
	  -o jsonpath="{.data.password}" | base64 -d && echo

argocd-status: ## Show ArgoCD pods and Applications
	kubectl --context $(KCTX) -n $(ARGOCD_NS) get pods
	kubectl --context $(KCTX) -n $(ARGOCD_NS) get applications,appprojects

teardown: cluster-down ## Alias for cluster-down
