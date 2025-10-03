variable "project" {
  description = "Project name"
  type        = string
  default     = "secure-capstone"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "domain_name" {
  description = "The domain name for the ACM certificate (e.g. api.example.com)"
  type        = string
}

variable "route53_zone_id" {
  description = "The Route 53 Hosted Zone ID to use for ACM DNS validation"
  type        = string
} 
