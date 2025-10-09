variable "project" {}
variable "vpc_id" {}
variable "private_db_subnet_ids" {
  type        = list(string)
  description = "Private database subnet IDs from the network layer"
}
variable "app_sg_id" {
  description = "Security group ID of the App layer"
}
variable "db_username" {}
variable "db_password" { sensitive = true }
variable "db_port" { default = 3306 }
