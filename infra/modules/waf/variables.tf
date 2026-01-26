variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to protect"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_rate_limit" {
  description = "Enable rate-based rule to limit requests per IP"
  type        = bool
  default     = true
}

variable "rate_limit_requests" {
  description = "Maximum requests per 5 minutes per IP address"
  type        = number
  default     = 2000
}

variable "enable_managed_rules" {
  description = "Enable AWS Managed Rules for common protections"
  type        = bool
  default     = true
}

variable "default_action" {
  description = "Default action for Web ACL (ALLOW or BLOCK)"
  type        = string
  default     = "ALLOW"
}
