# ===================AWS==================
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "az_a" {
  description = "AWS Availability Zone"
  type    = string
  default = "eu-west-1a"
}

variable "az_b" {
  description = "AWS Availability Zone"
  type    = string
  default = "eu-west-1b"
}

# ===================VPC+SUBNETS==================
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_a" {
  type    = string
  default = "10.0.0.0/20"
}

variable "public_subnet_cidr_b" {
  type    = string
  default = "10.0.16.0/20"
}

variable "private_subnet_cidr_a" {
  type    = string
  default = "10.0.32.0/20"
}
variable "private_subnet_cidr_b" {
  type    = string
  default = "10.0.48.0/20"
}

# ===================EKS Cluster==================
variable "cluster_name" {
  type    = string
  default = "ekspreg"
}

variable "node_group_name" {
  type    = string
  default = "ekspreg-ng-public1"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 2
}

variable "disk_size" {
  type    = number
  default = 20
}

# ===================Other==================
variable "kubernetes_version" {
  type    = string
  default = "1.29"
}