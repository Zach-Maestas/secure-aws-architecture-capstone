output "alb_dns_name" {
  value = module.app.alb_dns_name
}

output "s3_website_endpoint" {
  value = module.app.s3_website_endpoint
}
