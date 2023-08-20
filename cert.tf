resource "aws_acm_certificate" "default" {
  domain_name = var.domain_name
  subject_alternative_names = []
  validation_method = "DNS"

  tags = {
    Name = var.domain_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "default_cert_validation" {
  depends_on = [aws_acm_certificate.default]

  for_each = {
    for dvo in aws_acm_certificate.default.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name  = each.value.name
  records = [each.value.record]
  type = each.value.type

  zone_id = aws_route53_zone.dns_zone.zone_id
  ttl = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.default.arn

  validation_record_fqdns = [for record in aws_route53_record.default_cert_validation : record.fqdn]
}


resource "aws_lb_listener_certificate" "default" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate.default.arn

  depends_on = [aws_acm_certificate_validation.default]
}
