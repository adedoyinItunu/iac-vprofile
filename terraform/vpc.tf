# =============================================================================
# vpc.tf — VPC + public/private subnets + NAT gateway, via the official module.
# =============================================================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "vprofile-eks"
  cidr = "172.20.0.0/16"

  # First 3 AZs in whatever region we're in. Using slice() keeps the code
  # portable across regions instead of hardcoding "us-east-2a", etc.
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["172.20.1.0/24", "172.20.2.0/24", "172.20.3.0/24"]
  public_subnets  = ["172.20.4.0/24", "172.20.5.0/24", "172.20.6.0/24"]

  # Single NAT for cost: one NAT gateway is ~$32/month; three is ~$96/month.
  # Real production wants one per AZ for fault tolerance — bootcamp budget
  # picks the cheaper option.
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # EKS REQUIRES these tags. Without them, LoadBalancer Services in the
  # cluster will sit in "pending" forever because the AWS LB Controller
  # can't figure out which subnets to use.
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}
