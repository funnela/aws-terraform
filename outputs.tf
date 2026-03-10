output "database" {
  value = {
    hostname = aws_db_instance.database.address
    port = aws_db_instance.database.port
    username = aws_db_instance.database.username
    database = var.account
    password_secret_name = aws_ssm_parameter.db_password.name
  }
}

output "vpc" {
  value = {
    default_security_group_id = aws_security_group.default.id
    private_subnets = module.vpc.private_subnets
    public_subnets = module.vpc.public_subnets
  }
}

output "ecs" {
  value = {
    roles = {
        task_role_arn = aws_iam_role.task_role.arn
        execution_role_arn = aws_iam_role.task_execution_role.arn
    }
  }
}
