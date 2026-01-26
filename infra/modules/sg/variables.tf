variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "allow_http_from_cidr" {
  description = "CIDR blocks allowed to access ALB via HTTP (default: 0.0.0.0/0 for internet)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allow_https_from_cidr" {
  description = "CIDR blocks allowed to access ALB via HTTPS (default: 0.0.0.0/0 for internet)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8080
}
