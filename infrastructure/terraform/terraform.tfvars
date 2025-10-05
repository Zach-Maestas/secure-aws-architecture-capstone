# Project settings
project              = "secure-capstone"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
private_db_subnet_cidrs  = ["10.0.5.0/24", "10.0.6.0/24"]
azs                  = ["us-east-1a", "us-east-1b"]
region               = "us-east-1"

# Domain settings
# root_domain        = "zachmaestas-capstone.com"
# subdomain          = "api"
domain_name        = "api.zachmaestas-capstone.com"  # <-- Used for ACM + Route 53 A record
route53_zone_id    = "Z00547482WA2XUJ97RWO2"
