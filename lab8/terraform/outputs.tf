output "frontend_url" {
  value       = module.frontend.frontend_url
  description = "URL publica de la aplicacion via CloudFront"
}

output "bucket_name" {
  value       = module.frontend.bucket_name
  description = "Nombre del bucket S3 del frontend"
}

output "cloudfront_domain" {
  value       = module.frontend.cloudfront_domain
  description = "Dominio de la distribucion CloudFront"
}

output "deployment_information" {
  value = {
    frontend   = module.frontend.frontend_url
    bucket     = module.frontend.bucket_name
    cloudfront = module.frontend.cloudfront_domain
  }
  description = "Resumen del despliegue completo"
}
