variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "url-shortener"
}

variable "region" {
  description = "AWS region for the backend resources"
  type        = string
  default     = "eu-west-2"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state (must be globally unique)"
  type        = string
  default     = ""
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "enable_versioning" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption on the S3 bucket"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Purpose   = "terraform-state-backend"
  }
}

variable "enable_github_oidc" {
  description = "Enable GitHub OIDC provider and role for CI/CD"
  type        = bool
  default     = true
}

variable "github_repo" {
  description = "GitHub repository in format owner/repo (e.g., tomakady/ecs-v2)"
  type        = string
  default     = ""
}
