resource "aws_route53_zone" "dns_zone" {
  name = var.domain_name
}

resource "aws_route53_record" "default" {
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = "${var.domain_name}"
  type    = "A"
  allow_overwrite = true

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
