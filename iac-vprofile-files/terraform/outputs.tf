# =============================================================================
# outputs.tf — Values printed after a successful apply.
# These show up in the GitHub Actions log and other workflows can read them.
# =============================================================================

output "cluster_id" {
  description = "EKS cluster name (used as ID by AWS)."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL for the EKS control plane API."
  value       = module.eks.cluster_endpoint
}

output "region" {
  description = "AWS region the cluster runs in."
  value       = var.region
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}
