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

variable "k3s_token" {
  type      = string
  sensitive = true
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_user" {
  description = "PostgreSQL database user"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "secret_key" {
  description = "Application secret key"
  type        = string
  sensitive   = true
}

variable "ecr_credential_provider_ver" {
  description = "Version of ecr-credential-provider binary"
  type        = string
  default     = "v1.2.0"
}

variable "environment" {
  description = "App environment"
  type        = string
  default     = "produciton"
}


variable "testing_db_host" {
  description = "DB host in testing env"
  type        = string
  default     = ""
}