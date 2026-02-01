# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.tags.Name != null ? var.tags.Name : "url-shortener"}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      Name = "${var.tags.Name != null ? var.tags.Name : "url-shortener"}-alb"
    }
  )
}

# Target Group for ECS tasks (Blue)
resource "aws_lb_target_group" "blue" {
  name        = "${var.tags.Name != null ? var.tags.Name : "url-shortener"}-blue-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.tags.Name != null ? var.tags.Name : "url-shortener"}-blue-tg"
    }
  )

  # Allow deletion even if in use (CodeDeploy will be destroyed first)
  lifecycle {
    create_before_destroy = true
  }
}

# Target Group for ECS tasks (Green) - for blue/green deployments
resource "aws_lb_target_group" "green" {
  name        = "${var.tags.Name != null ? var.tags.Name : "url-shortener"}-green-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.tags.Name != null ? var.tags.Name : "url-shortener"}-green-tg"
    }
  )

  # Allow deletion even if in use (CodeDeploy will be destroyed first)
  lifecycle {
    create_before_destroy = true
  }
}

# HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}
