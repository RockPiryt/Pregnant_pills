output "k3s_public_ip" {
  description = "Publiczny adres IP instancji EC2"
  value = aws_spot_instance_request.preg_spot.public_ip
}

output "my_public_ip" {
  description = "Publiczny adres IP, z którego mogę łączyć się przez SSH"
  value = chomp(data.http.myip.response_body)
}

output "instance_url" {
  description = "Adres URL aplikacji webowej"
  value       = "http://${aws_spot_instance_request.preg_spot.public_ip}"
}

output "app_nodeport_url" {
  description = "URL aplikacji w dev przez NodePort"
  value       = "http://${aws_spot_instance_request.preg_spot.public_ip}:30080"
}

output "eip_public_ip" {
  value       = try(aws_eip.preg_eip.public_ip, null)
  description = "Elastic IP attached to the instance (if created)."
}


