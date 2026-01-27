# CloudWatch Log Group for WAF
resource "aws_cloudwatch_log_group" "waf" {
  name              = "/aws/waf/${var.project_name}"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-waf-logs"
    }
  )
}

# CloudWatch Log Stream
resource "aws_cloudwatch_log_stream" "waf" {
  name           = "${var.project_name}-waf-stream"
  log_group_name = aws_cloudwatch_log_group.waf.name
}

# WAF Web ACL
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.project_name}-waf"
  description = "WAF Web ACL for ${var.project_name}"
  scope       = "REGIONAL"

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "ALLOW" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "BLOCK" ? [1] : []
      content {}
    }
  }

  # AWS Managed Rules - Common Rule Set (OWASP Top 10)
  dynamic "rule" {
    for_each = var.enable_managed_rules ? [1] : []
    content {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 1

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.project_name}-CommonRuleSetMetric"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS Managed Rules - Known Bad Inputs
  dynamic "rule" {
    for_each = var.enable_managed_rules ? [1] : []
    content {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 2

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.project_name}-KnownBadInputsMetric"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS Managed Rules - Linux Operating System
  dynamic "rule" {
    for_each = var.enable_managed_rules ? [1] : []
    content {
      name     = "AWSManagedRulesLinuxRuleSet"
      priority = 3

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesLinuxRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.project_name}-LinuxRuleSetMetric"
        sampled_requests_enabled   = true
      }
    }
  }

  # Rate-based rule for DDoS protection
  dynamic "rule" {
    for_each = var.enable_rate_limit ? [1] : []
    content {
      name     = "RateLimitRule"
      priority = 4

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit              = var.rate_limit_requests
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.project_name}-RateLimitMetric"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-WAFMetric"
    sampled_requests_enabled   = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-waf"
    }
  )
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
