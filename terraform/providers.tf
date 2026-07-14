provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# --- Kubernetes / Helm providers pointed at the cluster we're creating -------
# These only become usable after the cluster exists; for `terraform plan` on
# a fresh workspace, that's fine — no resources of these providers are
# declared yet (they'll appear in the ArgoCD bootstrap PR).

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
