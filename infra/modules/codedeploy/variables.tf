variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the primary ALB target group (blue) - deprecated, use blue_target_group_arn instead"
  type        = string
  default     = ""
}

variable "blue_target_group_arn" {
  description = "ARN of the blue ALB target group"
  type        = string
}

variable "green_target_group_arn" {
  description = "ARN of the green ALB target group"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of the ALB HTTPS listener"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "ARN of the IAM role for CodeDeploy"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "deployment_config_name" {
  description = "CodeDeploy deployment configuration name. For ECS blue/green, use CodeDeployDefault.ECSAllAtOnce"
  type        = string
  default     = "CodeDeployDefault.ECSAllAtOnce"
}

variable "termination_wait_time_in_minutes" {
  description = "Number of minutes to wait after a successful blue/green deployment before terminating instances from the original environment"
  type        = number
  default     = 5
}
