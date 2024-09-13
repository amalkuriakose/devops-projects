resource "aws_lb_target_group" "target_group" {
  name     = "${var.project_name}-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = 2
    timeout             = 5
    interval            = 8
    matcher             = "200-299"
    path                = "/login"
    port                = 8080
    protocol            = "HTTP"
    unhealthy_threshold = 2
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-lb-tg"
    }
  )
}

resource "aws_security_group" "lb_sg" {
  name        = "${var.project_name}-lb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
      Name = "${var.project_name}-lb-sg"
    }
  )
}

resource "aws_lb" "lb" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-lb"
    }
  )
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-lb-listener"
    }
  )
}