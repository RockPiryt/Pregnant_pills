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