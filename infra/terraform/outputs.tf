# wyciagniecie ip isntancji
output "public_ip" {
    value = aws_spot_instance_request.preg_spot.public_ip
}

