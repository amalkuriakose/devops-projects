resource "aws_security_group" "efs_sg" {
  name        = "${var.project_name}-efs-sg"
  description = "Allow EFS Traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Allow EFS Traffic"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.instance_sg.id]
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
      Name = "${var.project_name}-efs-sg"
    }
  )
}

resource "aws_efs_file_system" "efs_file_system" {
  creation_token = "${var.project_name}-jenkins-file-system"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-jenkins-file-system"
    }
  )
}

resource "aws_efs_mount_target" "efs_mount_target" {
  for_each        = local.azs_set
  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = aws_subnet.private_subnets[each.key].id
  security_groups = [aws_security_group.efs_sg.id]
}