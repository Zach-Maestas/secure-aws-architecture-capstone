variable "project" {
  default = "secure-aws-architecture-capstone"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "project" {
  description = "Project name"
  default     = "secure-aws-architecture-capstone"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs (1 per AZ)"
  type        = list(string)
  default     = [
    "10.0.0.0/24", # AZ A
    "10.0.1.0/24"  # AZ B
  ]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs (2 per AZ)"
  type        = list(string)
  default     = [
    "10.0.2.0/24", # AZ A (EC2)
    "10.0.3.0/24", # AZ B (EC2)
    "10.0.4.0/24", # AZ A (RDS)
    "10.0.5.0/24"  # AZ B (RDS)
  ]
}
