resource "aws_ecs_cluster" "ecs_cluster" {
  name = "funnela-${var.account}"
}
