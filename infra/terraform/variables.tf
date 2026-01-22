variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "az" {
  description = "AWS Availability Zone"
  type        = string
  default     = "eu-west-1a"
}

variable "ssh_pub_key" {
  description = "ssh public key"
  type        = string
}

variable "my_ip" {
  description = "Public IP allowed for SSH"
  type        = string
}