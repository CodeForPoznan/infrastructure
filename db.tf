resource "aws_db_subnet_group" "private" {
  name = "private"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]
}

resource "random_password" "db_password" {
  length  = 128
  special = false
}

resource "aws_db_instance" "db" {
  identifier = "main-postgres"

  engine         = "postgres"
  engine_version = "12.8"

  instance_class    = "db.t2.micro"
  allocated_storage = 8

  username = "postgres"
  password = random_password.db_password.result

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  multi_az                = false
  db_subnet_group_name    = aws_db_subnet_group.private.name

  final_snapshot_identifier = "main-postgres-final-snapshot"

  depends_on = [
    random_password.db_password,
    aws_db_subnet_group.private,
  ]

  lifecycle {
    ignore_changes = [
      latest_restorable_time
    ]
  }
}
