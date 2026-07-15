# eks-gitops-platform

Opinionated Kubernetes platform: a **local `kind` cluster** or a
**production-style AWS EKS cluster** managed with Terraform, and a **GitOps
delivery flow** (ArgoCD, app-of-apps) that keeps the cluster in sync with this
repository.

> 🚧 **Status:** in progress. The `kind` cluster and the ArgoCD app-of-apps
> bootstrap are live and verified (see [screenshots](#-what-it-looks-like));
> platform addons, demo apps and observability are landing in incremental PRs.
> See the [roadmap](#-roadmap) below.

---

## 🎯 What this repo demonstrates

- **Infrastructure as Code** — the entire cluster (EKS variant) is a
  `terraform apply` away, using well-known community modules.
- **GitOps delivery** — `kubectl apply` is never used by humans; ArgoCD
  reconciles the live state to what lives in `platform/` and `apps/`.
- **Platform / application split** — cluster addons (ingress, cert-manager)
  are managed the same way as application workloads, but in a separate
  ArgoCD project with stricter sync policies.
- **Local-first dev loop** — you can bring up the whole thing on your laptop
  in a few minutes with `make cluster-up`, no cloud account required.

## 🏗️ Architecture

```mermaid
flowchart LR
    Dev[👤 Developer] -->|git push| Repo[(GitHub<br/>this repo)]
    Repo -->|webhook / poll| Argo[ArgoCD]

    subgraph Cluster["Kubernetes cluster (kind or EKS)"]
        Argo -->|syncs| Platform[Platform apps<br/>ingress-nginx · cert-manager]
        Argo -->|syncs| Apps[Application apps<br/>podinfo · sidebyside]
        Ingress[ingress-nginx] --> Apps
    end

    User((👥 End user)) -->|HTTP| Ingress
```

Two entry points, one delivery model:

| Path | Provisioned by | Cost | Use when |
|---|---|---|---|
| **`kind/`** | `make cluster-up` (Docker) | Free | Local dev, demos, learning |
| **`terraform/`** | `terraform apply` | ~$75–100/mo | Real EKS in AWS |

Both end up running the same `platform/` and `apps/` — the delivery layer is
cluster-agnostic.

## 🚀 Quick start (local)

Requirements: Docker, [kind](https://kind.sigs.k8s.io/), `kubectl`, `helm`, `make`.

> **On Windows:** run `make` from **Git Bash**, not PowerShell or `cmd`. The
> targets use POSIX shell syntax, and GNU Make picks its shell by looking for
> `sh.exe` on `PATH` — which it only finds under Git Bash. From PowerShell it
> falls back to `cmd.exe` and the recipes fail. Note that `bash` on `PATH` is
> often the WSL stub (`C:\Windows\system32\bash.exe`), which is *not* Git Bash.

```bash
make cluster-up          # spins up a 3-node kind cluster with ingress ports
make cluster-status      # sanity check: nodes + system pods
make bootstrap           # installs ArgoCD + applies the root app-of-apps
make argocd-password     # initial admin password
make argocd-ui           # port-forward to http://localhost:8080
```

Once `make bootstrap` finishes, ArgoCD is running and self-managing —
future changes to `platform/argocd/values.yaml` (or any other component)
land via PR, not `helm upgrade`. See
[`platform/argocd/README.md`](./platform/argocd/README.md) for details.

Tear it down:

```bash
make cluster-down
```

## 📸 What it looks like

After `make bootstrap`, two Applications are reconciling — both `Synced` and
`Healthy`, both owned by the `platform` AppProject:

![ArgoCD Applications — root and argocd, both Synced and Healthy](./docs/img/argocd-applications.png)

`root` is the **app-of-apps**: a single Application whose job is to create
other Applications from `platform/argocd/applications/`. Right now it manages
exactly one child — `argocd` itself:

![The root app-of-apps managing the argocd Application](./docs/img/argocd-root-tree.png)

And that child is the interesting part: **ArgoCD manages itself**. It was
installed once with Helm to break the chicken-and-egg problem, then adopted
into Git. From here, changing `platform/argocd/values.yaml` and merging a PR
is what upgrades ArgoCD — no `helm upgrade` by hand:

![ArgoCD self-managing: its own Deployments, ReplicaSets and Pods reconciled from Git](./docs/img/argocd-self-management.png)

## ☁️ Production path (AWS EKS)

See [`terraform/README.md`](./terraform/README.md) for the full setup. TL;DR:

```bash
cd terraform
terraform init
terraform plan
terraform apply
aws eks update-kubeconfig --name gitops-platform --region us-east-1
```

## 📁 Repository layout

```
.
├── kind/               kind cluster config + bootstrap scripts
├── terraform/          EKS + VPC (community modules), IAM, addons
├── platform/           Platform components delivered via GitOps
│   ├── argocd/         ArgoCD self-management + AppProjects + root app
│   ├── ingress-nginx/  (PR 3)
│   └── cert-manager/   (PR 3)
├── apps/               Application workloads delivered via GitOps
│   ├── podinfo/        (PR 4)
│   └── sidebyside/     (PR 4)
├── docs/
│   ├── architecture.md ADRs and diagrams
│   └── img/            screenshots used in this README
├── Makefile            developer entrypoints
└── .github/workflows/  fmt/validate/lint (Terraform + YAML)
```

## 🗺️ Roadmap

- [x] **PR 1** — Repo scaffolding, kind cluster, Terraform EKS (validate-only), docs
- [x] **PR 2** — ArgoCD bootstrap + app-of-apps pattern
- [ ] **PR 3** — Platform components via GitOps (ingress-nginx, cert-manager)
- [ ] **PR 4** — Demo apps (podinfo + sidebyside)
- [ ] **PR 5** — Observability stack (Prometheus + Grafana + Loki)
- [ ] **PR 6** — Cost analysis + disaster recovery runbook

## 📄 License

[MIT](./LICENSE)
