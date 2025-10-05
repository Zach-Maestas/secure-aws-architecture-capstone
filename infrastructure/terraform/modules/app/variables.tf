variable "project" {
  description = "The project name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate to use with the ALB"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to register the ASG with"
  type        = string
}
