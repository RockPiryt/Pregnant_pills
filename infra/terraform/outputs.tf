# wyciagniecie ip isntancji
output "public_ip" {
    description = "Publiczny adres IP instancji EC2"
    value = aws_spot_instance_request.preg_spot.public_ip
}

output "my_public_ip" {
  description = "Publiczny adres IP, z którego mogę łączyć się przez SSH"
  value = chomp(data.http.myip.response_body)
}

