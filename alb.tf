resource "aws_lb" "alb" {
  name               = "funnela-${var.account}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [
      aws_security_group.alb_sg.id,
      aws_security_group.default.id,
  ]
  subnets            = module.vpc.public_subnets
  idle_timeout       = 300
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.id
  port              = "443"
  protocol          = "HTTPS"
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.default.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.funnela_web.arn
  }
}

# Rabbit Management Console:

resource "aws_lb_target_group" "funnela_web" {
  name                 = "funnela-${var.account}-web"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    protocol = "HTTP"
    interval = 15
    timeout  = 10
    healthy_threshold = 2
    unhealthy_threshold = 4
    path     = "/"
    matcher = "200"
  }
}
