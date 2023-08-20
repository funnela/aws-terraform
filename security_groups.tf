#
# Default
#

resource "aws_security_group" "default" {
  name   = "funnela-${var.account}-default"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "default_in" {
  type              = "ingress"
  to_port           = -1
  from_port         = -1
  protocol          = "All"
  source_security_group_id = aws_security_group.default.id
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "default_out" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "All"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}


#
# ALB
#
resource "aws_security_group" "alb_sg" {
  name   = "funnela-${var.account}-alb"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  to_port           = 80
  from_port         = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  to_port           = 443
  from_port         = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_out" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "All"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}


#
# ECS Containers
#
resource "aws_security_group" "ecs_container_sg" {
  name   = "funnela-${var.account}-container-sg"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "from_alb" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "All"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id = aws_security_group.ecs_container_sg.id
}

resource "aws_security_group_rule" "container_out" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "All"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_container_sg.id
}


#
# Bastion Host
#
resource "aws_security_group" "bastion" {
  name   = "funnela-${var.account}-bastion-sg"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "bastion_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_out" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "All"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}
