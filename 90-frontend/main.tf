# =========================================================
# FRONTEND EC2 INSTANCE
# =========================================================

resource "aws_instance" "frontend" {
  ami           = data.aws_ami.joindevops.id
  instance_type = var.instance_type

  subnet_id = local.public_subnet_id

  vpc_security_group_ids = [
    local.frontend_sg_id
  ]

  associate_public_ip_address = true

  tags = merge(
    var.common_tags,
    {
      Name = local.resource_name
    }
  )
}


# =========================================================
# FRONTEND PROVISIONING
# =========================================================

resource "null_resource" "frontend" {
  triggers = {
    instance_id = aws_instance.frontend.id
  }

  connection {
    host     = aws_instance.frontend.public_ip
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "frontend.sh"
    destination = "/tmp/frontend.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/frontend.sh",
      "sudo sh /tmp/frontend.sh ${var.environment}"
    ]
  }

  depends_on = [
    aws_instance.frontend
  ]
}


# =========================================================
# STOP FRONTEND INSTANCE
# =========================================================

resource "aws_ec2_instance_state" "frontend" {
  instance_id = aws_instance.frontend.id
  state       = "stopped"

  depends_on = [
    null_resource.frontend
  ]
}


# =========================================================
# CREATE GOLDEN AMI
# =========================================================

resource "aws_ami_from_instance" "frontend" {
  name               = local.resource_name
  source_instance_id = aws_instance.frontend.id

  depends_on = [
    aws_ec2_instance_state.frontend
  ]
}


# =========================================================
# DELETE ORIGINAL FRONTEND INSTANCE
# =========================================================

resource "null_resource" "frontend_delete" {
  triggers = {
    instance_id = aws_instance.frontend.id
  }

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.frontend.id}"
  }

  depends_on = [
    aws_ami_from_instance.frontend
  ]
}


# =========================================================
# FRONTEND TARGET GROUP
# =========================================================

resource "aws_lb_target_group" "frontend" {
  name = local.resource_name

  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  deregistration_delay = 60

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/"
    matcher             = "200-299"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${local.resource_name}-tg"
    }
  )
}


# =========================================================
# FRONTEND LAUNCH TEMPLATE
# =========================================================

resource "aws_launch_template" "frontend" {
  name = local.resource_name

  image_id = aws_ami_from_instance.frontend.id

  instance_type = var.instance_type

  instance_initiated_shutdown_behavior = "terminate"

  update_default_version = true

  vpc_security_group_ids = [
    local.frontend_sg_id
  ]

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
# FRONTEND AUTO SCALING GROUP
# =========================================================

resource "aws_autoscaling_group" "frontend" {
  name = local.resource_name

  max_size         = 10
  min_size         = 1
  desired_capacity = 1

  health_check_grace_period = 180
  health_check_type         = "ELB"

  target_group_arns = [
    aws_lb_target_group.frontend.arn
  ]

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  vpc_zone_identifier = local.public_subnet_ids

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
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

  timeouts {
    delete = "10m"
  }
}


# =========================================================
# FRONTEND AUTO SCALING POLICY
# =========================================================

resource "aws_autoscaling_policy" "frontend" {
  name = "${local.resource_name}-frontend"

  policy_type = "TargetTrackingScaling"

  autoscaling_group_name = aws_autoscaling_group.frontend.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}


# =========================================================
# FRONTEND ALB LISTENER RULE
# =========================================================

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = data.aws_ssm_parameter.web_alb_listener_arn.value

  priority = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = [
        "expense-${var.environment}.${var.domain_name}"
      ]
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${local.resource_name}-listener-rule"
    }
  )
}