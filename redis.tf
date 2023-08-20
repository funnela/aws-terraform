resource "aws_elasticache_subnet_group" "default" {
  name       = "funnela-${var.account}-redis"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_cluster" "default" {
  cluster_id           = "funnela-${var.account}"
  engine               = "redis"
  node_type            = var.redis_instance_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  subnet_group_name = aws_elasticache_subnet_group.default.name
  security_group_ids = [
      aws_security_group.default.id,
  ]
}
