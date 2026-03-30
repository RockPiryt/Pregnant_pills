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



# ===================VPC==================
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_a" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public_subnet_cidr_b" {
  type    = string
  default = "10.0.2.0/24"
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
  default = 4
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "key_pair_name" {
  type    = string
  default = "kube-pregcare"
}

variable "ssh_pub_key" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}