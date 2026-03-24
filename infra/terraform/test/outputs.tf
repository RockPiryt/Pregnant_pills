output "k3s_public_ip" {
  description = "Publiczny adres IP instancji EC2"
  value = aws_spot_instance_request.preg_spot.public_ip
}

output "eip_public_ip" {
  value       = try(aws_eip.preg_eip.public_ip, null)
  description = "Elastic IP attached to the instance (if created)."
}


