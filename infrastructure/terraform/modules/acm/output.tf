output "certificate_arn" {
    description = "The ARN of the ACM certificate"
    # Expose the validated certificate ARN to ensure downstream resources wait for validation
    value       = aws_acm_certificate_validation.this.certificate_arn
    sensitive   = true
}
