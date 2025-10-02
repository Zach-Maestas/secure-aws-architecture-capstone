project              = "secure-capstone"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
azs                  = ["us-east-1a", "us-east-1b"]
acm_domain_name      = "api.zachmaestas-capstone.com"
route53_zone_id      = "Z02667996QEXAMPLE" # TODO: Replace with actual Route 53 Hosted Zone ID