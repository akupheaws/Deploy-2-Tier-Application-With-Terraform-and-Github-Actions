output "rds_endpoint" {
  description = "The connection endpoint for the RDS database instance."
  value       = aws_db_instance.rds.endpoint
  sensitive   = true
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host for SSH access."
  value       = aws_instance.bastion_host.public_ip
}

output "web_server_1_public_ip" {
  description = "Public IP address of the first web server."
  value       = aws_instance.web_server_1.public_ip
}

output "web_server_2_public_ip" {
  description = "Public IP address of the second web server."
  value       = aws_instance.web_server_2.public_ip
}

output "cloudfront_domain" {
  description = "The domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.domain_name
}