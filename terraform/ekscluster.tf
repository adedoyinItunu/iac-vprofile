# =============================================================================
# ekscluster.tf — EKS control plane + 2 managed node groups.
# All Class 2 corrections applied:
#   - module bumped from v19.19.1 -> v20.31+
#   - K8s version 1.27 -> 1.33
#   - AMI type AL2_x86_64 -> AL2023_x86_64_STANDARD
#   - enable_cluster_creator_admin_permissions = true (required by v20)
# =============================================================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31" # Class 2 correction

  cluster_name    = local.cluster_name
  cluster_version = "1.33" # Class 2 correction (was 1.27)

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  # Class 2 correction — without this, the role that creates the cluster
  # doesn't get cluster-admin access, and the deploy workflow can't talk to
  # the cluster.
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    # Class 2 correction — AL2 AMI is deprecated for K8s 1.32+
    ami_type = "AL2023_x86_64_STANDARD"
  }

  # Two small node groups. Real workloads need bigger instances; t3.small
  # is the bootcamp budget choice.
  eks_managed_node_groups = {
    one = {
      name           = "node-group-1"
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
    two = {
      name           = "node-group-2"
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
}
