# CodeDeploy Application
resource "aws_codedeploy_app" "main" {
  compute_platform = "ECS"
  name             = var.project_name

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-codedeploy-app"
    }
  )
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "main" {
  app_name              = aws_codedeploy_app.main.name
  deployment_group_name = "${var.project_name}-deployment-group"
  deployment_config_name = var.deployment_config_name
  service_role_arn       = var.codedeploy_role_arn

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_listener_arn]
      }
      target_group {
        name = split("/", split(":", var.blue_target_group_arn)[5])[1]
      }
      target_group {
        name = split("/", split(":", var.green_target_group_arn)[5])[1]
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-codedeploy-group"
    }
  )
}
