output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.arn
}

output "region" {
  description = "AWS region where the backend resources are located"
  value       = var.region
}

# GitHub Actions OIDC Outputs
output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions OIDC role (use this for ALL GitHub Secrets - consistent across all environments)"
  value       = var.enable_github_oidc && var.github_repo != "" ? aws_iam_role.github_actions_role[0].arn : null
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = var.enable_github_oidc && var.github_repo != "" ? aws_iam_openid_connect_provider.github_actions[0].arn : null
}
