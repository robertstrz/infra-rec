variable "app_name" {
  default = "my-app-name"
  type  = string
}

variable "aws-regions" {
  default = "us-east-1"
  type  = string
}

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}