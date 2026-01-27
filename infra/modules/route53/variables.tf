variable "project_name" {
  type = string
}

variable "environment" {
  type    = string
  default = ""
}

variable "domain_name" {
  type        = string
  description = "Root domain name (e.g., tomakady.com)"
}

variable "subdomain" {
  type        = string
  description = "Subdomain for the app (e.g., url.shortener for url.shortener.tomakady.com)"
}

variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name"
}

variable "alb_zone_id" {
  type        = string
  description = "ALB hosted zone ID"
}
