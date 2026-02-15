
# domena na Route 53
data "aws_route53_zone" "pk_domain" {
  name = "paulinakimak.com"
  private_zone = false
}

# tworzenie stałego publicznego IP(bo spot może mieć zmienne IP)
resource "aws_eip" "preg_eip" {
  tags = { Name = "preg-eip" }
}
# powiązanie EIP z instacja spot
resource "aws_eip_association" "preg_assoc" {
  instance_id   = aws_spot_instance_request.preg_spot.spot_instance_id
  allocation_id = aws_eip.preg_eip.id
}
# utworzenie rekordu dns z subdomena dla EIP  (preg.paulinakimak.com)
resource "aws_route53_record" "preg_app" {
  zone_id = data.aws_route53_zone.pk_domain.zone_id
  name    = "preg"
  type    = "A"
  ttl     = 300
  records = [aws_eip.preg_eip.public_ip]
}
