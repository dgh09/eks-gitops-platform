variable "region" {
  description = "AWS region to deploy the cluster into."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name — also used as a prefix for related resources."
  type        = string
  default     = "gitops-platform"
}

variable "kubernetes_version" {
  description = "EKS control-plane version. Bump one minor at a time."
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the cluster VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "node_instance_types" {
  description = "EC2 instance types the managed node group can use."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 4
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default = {
    Project   = "eks-gitops-platform"
    ManagedBy = "terraform"
  }
}
