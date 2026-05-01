# =============================================================================
# variables.tf — Input variables.
# =============================================================================

variable "region" {
  description = "AWS region for all resources. Stay in one region for the entire bootcamp."
  type        = string
  default     = "us-east-2"
}

variable "clustername" {
  description = "Base name for the EKS cluster. A random 8-char suffix is appended at apply time."
  type        = string
  default     = "vprofile-eks"
}
