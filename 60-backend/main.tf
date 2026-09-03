# =========================================================
# BACKEND EC2 INSTANCE
# =========================================================

resource "aws_instance" "backend" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"

  subnet_id = local.private_subnet_id

  vpc_security_group_ids = [
    local.backend_sg_id
  ]

  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              echo "Backend server setup started"

              # Add your backend application installation
              # commands here.

              echo "Backend server setup completed"
              EOF

  tags = merge(
    var.common_tags,
    {
      Name = local.resource_name
    }
  )
}


# =========================================================
# BACKEND TARGET GROUP
# =========================================================

resource "aws_lb_target_group" "backend" {
  name = substr(
    "${var.project_name}-${var.environment}-backend",
    0,
    32
  )

  port     = 8080
  protocol = "HTTP"

  vpc_id = local.vpc_id

  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${local.resource_name}-tg"
    }
  )
}


# =========================================================
# REGISTER BACKEND EC2 WITH TARGET GROUP
# =========================================================

resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = aws_lb_target_group.backend.arn
  target_id        = aws_instance.backend.id
  port             = 8080
}


# =========================================================
# APPLICATION ALB LISTENER RULE
# =========================================================

resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value

  priority = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = [
        "backend-${var.environment}.${var.domain_name}"
      ]
    }
  }
}


# =========================================================
# ROUTE53 RECORD
# =========================================================
#
# The application ALB already exists.
# We therefore retrieve the ALB through the listener ARN
# instead of creating another ALB.
# =========================================================

data "aws_lb" "app_alb" {
  arn = replace(
    data.aws_ssm_parameter.app_alb_listener_arn.value,
    "/listeners/.*$/",
    ""
  )
}

resource "aws_route53_record" "backend" {
  zone_id = var.zone_id

  name = "backend-${var.environment}.${var.domain_name}"

  type = "A"

  alias {
    name                   = data.aws_lb.app_alb.dns_name
    zone_id                = data.aws_lb.app_alb.zone_id
    evaluate_target_health = true
  }
}


# =========================================================
# AUTO SCALING LAUNCH TEMPLATE
# =========================================================

resource "aws_launch_template" "backend" {
  name_prefix = "${local.resource_name}-"

  image_id = data.aws_ami.joindevops.id

  instance_type = "t3.micro"

  vpc_security_group_ids = [
    local.backend_sg_id
  ]

  user_data = base64encode(<<-EOF
              #!/bin/bash

              echo "Backend application server starting"

              # Add your backend installation/deployment
              # commands here.

              echo "Backend application server started"
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name = local.resource_name
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.common_tags,
      {
        Name = "${local.resource_name}-volume"
      }
    )
  }
}


# =========================================================
# AUTO SCALING GROUP
# =========================================================

resource "aws_autoscaling_group" "backend" {
  name = local.resource_name

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  vpc_zone_identifier = local.private_subnet_ids

  target_group_arns = [
    aws_lb_target_group.backend.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }
}