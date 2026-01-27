# ============================================================================
# VPC Module
# ============================================================================
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr    = "10.0.0.0/16"
  region      = local.region
  
  availability_zones   = ["eu-west-2a", "eu-west-2b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.common_tags
}

# ============================================================================
# Security Groups Module
# ============================================================================
module "sg" {
  source = "../../modules/sg"

  vpc_id                = module.vpc.vpc_id
  vpc_cidr              = module.vpc.vpc_cidr
  allow_http_from_cidr  = ["0.0.0.0/0"]
  allow_https_from_cidr  = ["0.0.0.0/0"]
  app_port              = 8080

  tags = local.common_tags
}

# ============================================================================
# DynamoDB Module
# ============================================================================
module "dynamodb" {
  source = "../../modules/dynamodb"

  project_name = "url-shortener"

  enable_point_in_time_recovery = true

  tags = local.common_tags
}

# ============================================================================
# IAM Module
# ============================================================================
module "iam" {
  source = "../../modules/iam"

  project_name = "url-shortener"
  aws_region   = local.region

  enable_dynamodb_access = true
  dynamodb_table_arns    = [module.dynamodb.table_arn]

  enable_github_oidc = false  # OIDC is now managed in global/backend bootstrap
  github_repo        = ""     # Not needed when using global OIDC

  terraform_state_bucket = "url-shortener-terraform-state"
  terraform_lock_table   = "terraform-state-lock"

  # Pass ECR and ECS resources for GitHub Actions permissions
  ecr_repository_arns = [module.ecr.repository_arn]
  ecs_cluster_arns    = [module.ecs.cluster_arn]
  ecs_service_arns     = [module.ecs.service_id]

  tags = local.common_tags
}

# ============================================================================
# ECR Module
# ============================================================================
module "ecr" {
  source = "../../modules/ecr"

  project_name         = "url-shortener"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  image_count_to_keep  = 10

  tags = local.common_tags
}

# ============================================================================
# Route53 Module (needed for ACM validation)
# ============================================================================
module "route53" {
  source = "../../modules/route53"

  project_name = "url-shortener"
  domain_name  = "tomakady.com"
  subdomain    = "url.shortener"

  # Will be set after ALB is created
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_hosted_zone_id
}

# ============================================================================
# ACM Module (SSL Certificate)
# ============================================================================
module "acm" {
  source = "../../modules/acm"

  project_name = "url-shortener"
  domain_name  = "url.shortener.tomakady.com"
  zone_id      = module.route53.zone_id

  tags = local.common_tags
}

# ============================================================================
# ALB Module
# ============================================================================
module "alb" {
  source = "../../modules/alb"

  subnet_ids      = module.vpc.public_subnet_ids
  security_group_id = module.sg.alb_security_group_id
  certificate_arn = module.acm.certificate_arn
  vpc_id          = module.vpc.vpc_id
  app_port        = 8080

  tags = local.common_tags
}

# ============================================================================
# WAF Module
# ============================================================================
module "waf" {
  source = "../../modules/waf"

  project_name = "url-shortener"
  alb_arn      = module.alb.alb_arn

  tags = local.common_tags
}

# ============================================================================
# ECS Module
# ============================================================================
module "ecs" {
  source = "../../modules/ecs"

  project_name = "url-shortener"
  aws_region   = local.region

  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.sg.ecs_tasks_security_group_id
  target_group_arn      = module.alb.target_group_arn
  alb_listener_arn      = module.alb.https_listener_arn

  ecr_repository_url = module.ecr.repository_url
  image_tag         = "latest" # Change this for deployments

  container_name = "app"
  container_port = 8080

  task_cpu    = "256"
  task_memory = "512"
  desired_count = 1

  log_retention_days = 7

  task_execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn           = module.iam.task_role_arn

  environment_variables = [
    {
      name  = "TABLE_NAME"
      value = module.dynamodb.table_name
    }
  ]

  tags = local.common_tags
}

# ============================================================================
# CodeDeploy Module
# ============================================================================
module "codedeploy" {
  source = "../../modules/codedeploy"

  project_name = "url-shortener"

  ecs_cluster_name      = module.ecs.cluster_name
  ecs_service_name      = module.ecs.service_name
  blue_target_group_arn = module.alb.blue_target_group_arn
  green_target_group_arn = module.alb.green_target_group_arn
  alb_listener_arn      = module.alb.https_listener_arn
  codedeploy_role_arn   = module.iam.codedeploy_role_arn

  tags = local.common_tags
}
