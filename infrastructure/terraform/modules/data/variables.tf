variable "project" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_db_subnet_ids" {
  type        = list(string)
  description = "Private database subnet IDs from the network layer"
}

variable "app_sg_id" {
  description = "Security group ID of the App layer"
}

variable "db_port" {
  description = "Port for the database"
  type        = number
  default     = 5432 # PostgreSQL default port
}

variable "db_username" {
  description = "Username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
}