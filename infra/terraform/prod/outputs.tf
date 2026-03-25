output "rds_endpoint" {
  value = aws_db_instance.preg_postgres.address # without port
}
