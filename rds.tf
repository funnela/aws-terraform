resource "aws_db_subnet_group" "default" {
  name       = "funnela-${var.account}-db"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_parameter_group" "default" {
  name   = "funnela-${var.account}-db-pg"
  family = "postgres11"

  parameter {
    apply_method = "pending-reboot"
    name = "max_connections"
    value = "100"
  }
}

resource "aws_db_instance" "database" {
  identifier      = "funnela-${var.account}"

  allocated_storage    = var.db_storage
  max_allocated_storage = var.db_max_storage
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "11"
  instance_class       = var.db_instance_type
  username             = "postgres"
  password             = random_password.db_password.result
  final_snapshot_identifier = "funnela-${var.account}-rds-final-snapshot"
  db_subnet_group_name = aws_db_subnet_group.default.name
  parameter_group_name = aws_db_parameter_group.default.name

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  backup_retention_period = 14
  delete_automated_backups = false

  vpc_security_group_ids = [
      aws_security_group.default.id,
  ]
}
