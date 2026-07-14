output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint. Feed into kubectl / provider config."
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the control plane."
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group created for the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider — needed for IRSA / Pod Identity."
  value       = module.eks.oidc_provider_arn
}

output "vpc_id" {
  description = "ID of the VPC hosting the cluster."
  value       = module.vpc.vpc_id
}

output "configure_kubectl" {
  description = "Command to update local kubeconfig."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}
