# EKS variant (Terraform)

Provisions a production-style **EKS cluster** on AWS using well-maintained
community modules ([`terraform-aws-modules/vpc`](https://github.com/terraform-aws-modules/terraform-aws-vpc)
and [`terraform-aws-modules/eks`](https://github.com/terraform-aws-modules/terraform-aws-eks)).

## What gets created

- VPC (`10.20.0.0/16`) across 2 AZs, public + private subnets, single NAT.
- EKS control plane (v1.30) with public endpoint and cluster-creator admin.
- Managed node group: 2× `t3.medium`, autoscaling 2–4.
- EKS-managed addons: CoreDNS, kube-proxy, VPC CNI, Pod Identity Agent.

## Cost heads-up

Roughly **$75–100/month** if left running:

| Component | ~USD/month |
|---|---|
| EKS control plane | $73 |
| 2× t3.medium on-demand | $60 (24/7) |
| NAT gateway | $32 + data |
| ALB (once ingress is up) | $16+ |

Destroy when you're done demoing.

## Usage

```bash
terraform init
terraform plan
terraform apply

aws eks update-kubeconfig --name gitops-platform --region us-east-1
kubectl get nodes
```

## Tear down

```bash
terraform destroy
```

## Design notes

- **Community modules on purpose.** Rolling your own EKS module is a rabbit
  hole (IRSA, OIDC, addons, ALB controller IAM). The community modules solve
  all of that and are what most shops actually use.
- **VPC CIDR `10.20.0.0/16`** picked to not collide with the `10.244.0.0/16`
  pods used in the [kind variant](../kind/) so a laptop can run both.
- **Public endpoint** kept enabled because this is a portfolio cluster. In a
  real environment: private endpoint + VPN/bastion, or `endpoint_public_access_cidrs`
  restricted to office/VPN CIDRs.
- **Pod Identity over IRSA** for new workloads (Pod Identity Agent addon is
  installed). Simpler than IRSA, no OIDC juggling per service account.
