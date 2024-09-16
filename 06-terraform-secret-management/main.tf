data "aws_secretsmanager_secret" "secret" {
  name = "test-secret"
}

data "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

locals {
  db_cred = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = local.db_cred.username
  password             = local.db_cred.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}