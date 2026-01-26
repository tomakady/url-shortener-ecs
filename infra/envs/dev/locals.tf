locals {
  # Common tags applied to all resources
  common_tags = {
    Name        = "url-shortener-dev"
    Environment = "dev"
    Project     = "url-shortener"
    ManagedBy   = "Terraform"
  }

  # Name prefix for resource naming
  name_prefix = "url-shortener-dev"

  # Region
  region = "eu-west-2"
}
