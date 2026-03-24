# Route 53 domain
data "aws_route53_zone" "pk_domain" {
  name = "paulinakimak.com"
  private_zone = false
}

# Route 53 record (subdomain preg.paulinakimak.com) for EIP
resource "aws_route53_record" "preg_app" {
  zone_id = data.aws_route53_zone.pk_domain.zone_id
  name    = "preg"
  type    = "A"
  ttl     = 300
  records = [aws_eip.preg_eip.public_ip]
}
