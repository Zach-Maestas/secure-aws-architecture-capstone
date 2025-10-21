output "alb_sg_id" {
  description = "Security group ID for the ALB"
  value = aws_security_group.alb.id
}

output "ec2_sg_id" {
  description = "Security group ID for the EC2 instances"
  value = aws_security_group.ec2.id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value = aws_lb_target_group.app.arn
}
