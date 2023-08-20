resource "random_password" "db_password" {
  length = 24
  special = false
}

resource "aws_ssm_parameter" "db_password" {
  name  = "funnela-${var.account}-db-password"
  type  = "SecureString"
  value = random_password.db_password.result
}

resource "random_password" "salt" {
  length = 32
  special = false
}

resource "aws_ssm_parameter" "salt" {
  name  = "funnela-${var.account}-salt"
  type  = "SecureString"
  value = random_password.salt.result
}


resource "random_password" "master" {
  length = 24
  special = false
}

resource "aws_ssm_parameter" "master" {
  name  = "funnela-${var.account}-master-password"
  type  = "SecureString"
  value = random_password.master.result
}
