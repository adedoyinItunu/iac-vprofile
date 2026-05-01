# =============================================================================
# terraform.tf — Provider versions and S3 backend for state.
#
# This file is one of the FIRST things Terraform reads. It declares which
# providers we need and where the state file lives. The bucket name gets
# injected at workflow runtime via -backend-config; we don't hardcode it
# in the file because then it would be different per developer / per env.
# =============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.95, < 6.0"   # Class 2 correction — EKS module v20 needs >=5.95
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }

  # State lives in S3, not on the workflow runner.
  # The runner is destroyed every job — local state would vanish.
  backend "s3" {
    bucket = "vprofile-tfstate-globalitunu-2026"   
    key    = "terraform.tfstate"
    region = "us-east-2"                       
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region = var.region
}
