output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "bastion_public_ip" {
  value = aws_instance.bastion_host.public_ip
}

output "web_server_1_public_ip" {
  value = aws_instance.web_server_1.public_ip
}

output "web_server_2_public_ip" {
  value = aws_instance.web_server_2.public_ip
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}