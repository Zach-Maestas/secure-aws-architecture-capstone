output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "ec2_sg_id" {
  value = aws_security_group.ec2.id
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}
