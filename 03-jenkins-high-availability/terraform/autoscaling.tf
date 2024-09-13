resource "aws_security_group" "instance_sg" {
  name        = "${var.project_name}-instance-sg"
  description = "Allow Jenkins Traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Allow Jenkins Traffic"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-instance-sg"
    }
  )
}

data "aws_iam_policy_document" "iam_trust_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "ssm_iam_policy" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "sm_kms_iam_policy_document" {
  statement {
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:ListSecrets"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "sm_kms_iam_policy" {
  name   = "${var.project_name}-secret-manager-kms-ec2-policy"
  policy = data.aws_iam_policy_document.sm_kms_iam_policy_document.json
}

resource "aws_iam_role" "ec2_iam_role" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.iam_trust_policy_document.json
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-ec2-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ssm_iam_role_policy_attachment" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = data.aws_iam_policy.ssm_iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "sm_kms_iam_role_policy_attachment" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = aws_iam_policy.sm_kms_iam_policy.arn
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_iam_role.name
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-instance-profile"
    }
  )
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.tftpl")
  vars = {
    efs_dns_name = aws_efs_file_system.efs_file_system.dns_name
  }
}

resource "aws_launch_template" "launch_template" {
  name                   = "${var.project_name}-launch-template"
  image_id               = data.aws_ami.ami.id
  instance_type          = var.asg_lt_instance_type
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 10
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.iam_instance_profile.arn
  }

  #user_data = filebase64("${path.module}/user-data.sh")
  user_data = base64encode(data.template_file.user_data.rendered)

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.common_tags,
      {
        Name = "${var.project_name}-ec2-server"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-launch-template"
    }
  )
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = "${var.project_name}-autoscaling-group"
  vpc_zone_identifier  = [for subnet in aws_subnet.private_subnets : subnet.id]
  desired_capacity     = 1
  max_size             = 5
  min_size             = 1
  target_group_arns    = [aws_lb_target_group.target_group.arn]
  termination_policies = ["OldestInstance"]
  default_cooldown     = 180
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  instance_maintenance_policy {
    min_healthy_percentage = 100
    max_healthy_percentage = 110
  }
  tag {
    key                 = "Name"
    value               = "${var.project_name}-autoscaling-group"
    propagate_at_launch = false
  }
  tag {
    key                 = "created-by"
    value               = "Terraform"
    propagate_at_launch = false
  }
  lifecycle {
    replace_triggered_by = [
      aws_launch_template.launch_template
    ]
  }
}

resource "aws_autoscaling_policy" "autoscaling_policy" {
  name                      = "${var.project_name}-autoscaling-policy"
  autoscaling_group_name    = aws_autoscaling_group.autoscaling_group.name
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 180
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}