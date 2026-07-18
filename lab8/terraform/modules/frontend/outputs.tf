output "frontend_url" {
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
  description = "URL HTTPS de la aplicacion via CloudFront"
}

output "bucket_name" {
  value       = aws_s3_bucket.frontend.bucket
  description = "Nombre del bucket S3"
}

output "cloudfront_domain" {
  value       = aws_cloudfront_distribution.frontend.domain_name
  description = "Dominio CloudFront sin https"
}
