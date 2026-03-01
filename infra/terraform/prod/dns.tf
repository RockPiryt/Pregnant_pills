# Route 53 domain
data "aws_route53_zone" "pk_domain" {
  name         = "paulinakimak.com"
  private_zone = false
}

# Route 53 record (subdomain preg.paulinakimak.com)
resource "aws_route53_record" "preg_app" {
  zone_id = data.aws_route53_zone.pk_domain.zone_id
  name    = "preg"
  type    = "A"

  alias {
    name                   = aws_lb.preg_alb.dns_name
    zone_id                = aws_lb.preg_alb.zone_id
    evaluate_target_health = true
  }
}

# AWS Certificate Manager Certificate for subdomain
resource "aws_acm_certificate" "preg_aws_cert" {
  domain_name       = "preg.paulinakimak.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "preg.paulinakimak.com"
  }
}

# DNS validation records
resource "aws_route53_record" "preg_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.preg_aws_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.pk_domain.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "preg_cert_validation" {
  certificate_arn         = aws_acm_certificate.preg_aws_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.preg_cert_validation : record.fqdn]
}



