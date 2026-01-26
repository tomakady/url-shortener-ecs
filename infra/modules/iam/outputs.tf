output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "github_oidc_provider_arn" {
  value = var.enable_github_oidc ? aws_iam_openid_connect_provider.github_actions[0].arn : null
}

output "github_actions_role_arn" {
  value = var.enable_github_oidc ? aws_iam_role.github_actions_role[0].arn : null
}

output "autoscaling_role_arn" {
  value = var.enable_autoscaling ? aws_iam_role.ecs_autoscaling_role[0].arn : null
}

output "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy role"
  value       = aws_iam_role.codedeploy_role.arn
}
