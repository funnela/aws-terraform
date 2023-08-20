resource "aws_ecs_task_definition" "funnela_web" {
  family                   = "funnela-web-${var.account}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.web_service_cpu
  memory                   = var.web_service_mem
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "web",
    "image": "${var.docker_image_web}:${var.docker_image_version}",
    "cpu": 1024,
    "memory": 2048,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_ecs_cluster.ecs_cluster.name}/funnela-${var.account}-web",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-stream-prefix": "funnela-web",
        "awslogs-create-group": "true"
      }
    },
    "environment": [
      {"name": "REDIS_DSN", "value": "tcp://${aws_elasticache_cluster.default.cache_nodes.0.address}:${aws_elasticache_cluster.default.cache_nodes.0.port}"},
      {"name": "DATABASE_HOST", "value": "${aws_db_instance.database.address}"},
      {"name": "DATABASE_PORT", "value": "${aws_db_instance.database.port}"},
      {"name": "DATABASE_NAME", "value": "${var.account}"},
      {"name": "DATABASE_USER", "value": "${aws_db_instance.database.username}"}
    ],
    "secrets": [
      {"name": "DATABASE_PASSWORD", "valueFrom": "${aws_ssm_parameter.db_password.name}"},
      {"name": "SECURITY_SALT", "valueFrom": "${aws_ssm_parameter.salt.name}"},
      {"name": "SUPERVISOR_PASSWORD", "valueFrom": "${aws_ssm_parameter.master.name}"}
    ]
  }
]
TASK_DEFINITION

}


resource "aws_ecs_service" "funnela-web" {
  name            = "funnela-web-${var.account}"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.funnela_web.arn
  desired_count   = var.web_service_scale
  launch_type = "FARGATE"
  enable_ecs_managed_tags = true
  propagate_tags = "TASK_DEFINITION"

  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 50

  deployment_circuit_breaker {
    enable = true
    rollback = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.funnela_web.arn
    container_name   = "web"
    container_port   = 80
  }

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [
        aws_security_group.ecs_container_sg.id,
        aws_security_group.default.id,
    ]
  }
}
