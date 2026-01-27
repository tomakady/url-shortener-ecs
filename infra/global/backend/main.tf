# Generate a random suffix for the bucket name if not provided
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name != "" ? "${var.state_bucket_name}-${random_id.bucket_suffix.hex}" : "${var.project_name}-terraform-state-${random_id.bucket_suffix.hex}"

  tags = var.tags
}

# Enable versioning on the state bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  count = var.enable_encryption ? 1 : 0

  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls       = true
  restrict_public_buckets   = true
}

# Prevent accidental deletion
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "prevent-deletion"
    status = "Enabled"


    # Future proofing for newer provider versions by filtering on the prefix
    filter {
      prefix = "terraform/state/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# Data source for AWS account ID
data "aws_caller_identity" "current" {}

# GitHub OIDC Provider (account-wide, one per AWS account)
resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.enable_github_oidc && var.github_repo != "" ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-github-oidc-provider"
    }
  )
}

# GitHub Actions Role (shared across all environments)
resource "aws_iam_role" "github_actions_role" {
  count       = var.enable_github_oidc && var.github_repo != "" ? 1 : 0
  name        = "${var.project_name}-github-actions-role"
  description = "GitHub Actions OIDC role for all environments"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github_actions[0].arn
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:${var.github_repo}:*"
          ]
        }
      }
    }]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-github-actions-role"
    }
  )
}

# GitHub Actions Role Policy (broad permissions for all environments)
resource "aws_iam_role_policy" "github_actions_policy" {
  count = var.enable_github_oidc && var.github_repo != "" ? 1 : 0
  name  = "${var.project_name}-github-actions-policy"
  role  = aws_iam_role.github_actions_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:HeadObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-*",
          "arn:aws:s3:::${var.project_name}-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = "arn:aws:dynamodb:${var.region}:*:table/${var.dynamodb_table_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:CreateRepository",
          "ecr:DescribeRepositories",
          "ecr:ListTagsForResource",
          "ecr:GetLifecyclePolicy"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:CreateService",
          "ecs:DeleteService",
          "ecs:UpdateService",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:TagResource",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeClusters",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeTasks"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "elasticloadbalancing:*",
          "route53:*",
          "acm:*",
          "logs:*",
          "dynamodb:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:ListDeployments",
          "codedeploy:ListApplicationRevisions",
          "codedeploy:StopDeployment",
          "codedeploy:ListTagsForResource",
          "codedeploy:TagResource",
          "codedeploy:UntagResource",
          "codedeploy:CreateApplication",
          "codedeploy:DeleteApplication",
          "codedeploy:GetDeploymentGroup",
          "codedeploy:ListDeploymentGroups",
          "codedeploy:CreateDeploymentGroup",
          "codedeploy:UpdateDeploymentGroup",
          "codedeploy:DeleteDeploymentGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "wafv2:GetWebACL",
          "wafv2:ListWebACLs",
          "wafv2:CreateWebACL",
          "wafv2:UpdateWebACL",
          "wafv2:DeleteWebACL",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "wafv2:ListResourcesForWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:ListTagsForResource",
          "wafv2:TagResource",
          "wafv2:UntagResource",
          "wafv2:GetLoggingConfiguration",
          "wafv2:PutLoggingConfiguration",
          "wafv2:DeleteLoggingConfiguration",
          "wafv2:ListLoggingConfigurations"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:ListRoles",
          "iam:GetOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}
