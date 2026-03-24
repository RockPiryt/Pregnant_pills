output "k3s_public_ip" {
  description = "Publiczny adres IP instancji EC2"
  value = aws_spot_instance_request.preg_spot.public_ip
}

output "instance_url" {
  description = "Adres URL aplikacji webowej"
  value       = "http://${aws_spot_instance_request.preg_spot.public_ip}"
}

output "app_nodeport_url" {
  description = "URL aplikacji w dev przez NodePort"
  value       = "http://${aws_spot_instance_request.preg_spot.public_ip}:30080"
}


