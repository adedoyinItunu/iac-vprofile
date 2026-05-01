# =============================================================================
# ecr.tf — Elastic Container Registry for the vprofile app images.
# Added in Class 2 (lets Terraform manage the ECR repo instead of clicking
# through the AWS console manually).
# =============================================================================

resource "aws_ecr_repository" "vprofileapp" {
  name                 = "vprofileapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # AWS scans for vulnerabilities on every push
  }
}

output "ecr_repository_url" {
  description = "URL of the ECR repository — pass this to the application workflow."
  value       = aws_ecr_repository.vprofileapp.repository_url
}
