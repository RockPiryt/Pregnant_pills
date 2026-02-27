output "preg_certificate_arn" {
  value = aws_acm_certificate_validation.preg_cert_validation.certificate_arn
}

output "alb_dns_name" {
  value = aws_lb.preg_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.preg_postgres.endpoint
}