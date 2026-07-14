# Local cluster (`kind`)

Config for a 3-node [kind](https://kind.sigs.k8s.io/) cluster that mirrors
the topology and CIDRs of the EKS variant, so manifests are portable.

## Highlights

- **Control-plane + 2 workers** — realistic scheduling behavior (real EKS
  runs workers only, but locally the control-plane is a normal node too).
- **`ingress-ready=true` label** on the control-plane so ingress-nginx will
  schedule its DaemonSet there.
- **Host port mappings 80/443** — once ingress-nginx is installed, you'll
  reach services at `http://localhost` and `https://localhost`.
- **Standard CIDRs** (`10.244.0.0/16` pods, `10.96.0.0/16` services) matching
  common EKS deployments.

## Usage

From the repo root:

```bash
make cluster-up      # kind create cluster --config kind/cluster.yaml
make cluster-status  # nodes + kube-system pods
make cluster-down    # kind delete cluster --name gitops-platform
```
