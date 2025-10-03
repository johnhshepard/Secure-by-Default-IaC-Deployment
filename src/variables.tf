variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1" # Change this to your preferred region
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "appadmin"
}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  sensitive   = true # Use sensitive to hide in plan output
}