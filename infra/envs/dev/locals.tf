locals {
  # Common tags applied to all resources
  common_tags = {
    Name      = "url-shortener"
    Project   = "url-shortener"
    ManagedBy = "Terraform"
  }

  # Name prefix for resource naming
  name_prefix = "url-shortener"

  # Region
  region = "eu-west-2"
}
