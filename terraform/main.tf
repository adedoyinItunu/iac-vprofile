# =============================================================================
# main.tf — AZ lookup, random suffix, computed cluster name.
# =============================================================================

# Fetch the list of AZs available in the chosen region.
# Filtering by "opt-in-not-required" excludes the local zones and special
# regions that need explicit opt-in (e.g. ap-east-1) — keeps us safe.
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Generate an 8-char lowercase string the first time we apply.
# Stored in state, so it stays stable across re-runs.
# Why: if you destroy the cluster and recreate, EKS won't let you re-use the
# name immediately (cleanup takes time). The suffix sidesteps that.
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  cluster_name = "${var.clustername}-${random_string.suffix.result}"
}
