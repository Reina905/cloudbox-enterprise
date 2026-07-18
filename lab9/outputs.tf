#  URL de la cola SQS principal 
output "documents_queue_url" {
  value       = aws_sqs_queue.documents_queue.id
  description = "URL de la cola SQS documents-queue"
}

#  ARN de la cola SQS principal 
output "documents_queue_arn" {
  value       = aws_sqs_queue.documents_queue.arn
  description = "ARN de la cola SQS documents-queue"
}

#  ARN de la Dead Letter Queue 
output "documents_dlq_arn" {
  value       = aws_sqs_queue.documents_dlq.arn
  description = "ARN de la Dead Letter Queue documents-dlq"
}

#  ARN de la Lambda Productora 
output "producer_lambda_arn" {
  value       = aws_lambda_function.producer.arn
  description = "ARN de la Lambda Productora (documents-producer)"
}

#  ARN de la Lambda Consumidora 
output "consumer_lambda_arn" {
  value       = aws_lambda_function.consumer.arn
  description = "ARN de la Lambda Consumidora (documents-consumer)"
}

# Outputs de Labs anteriores
# Pero aja se puede hacer terraform output en cada laboratorio pero en la guia dice que desde el 9 so

# URL del API Gateway (Lab 7)
output "api_url" {
  value       = "https://${data.aws_api_gateway_rest_api.lab7_api.id}.execute-api.${var.aws_region}.amazonaws.com/dev"
  description = "URL del API Gateway REST del Lab 7"
}

# URL del Frontend en CloudFront (Lab 8)
output "frontend_url" {
  value       = "https://${data.aws_cloudfront_distribution.lab8_frontend.domain_name}"
  description = "URL pública del frontend React (CloudFront)"
}

# Dominio de CloudFront sin el https:// (Lab 8)
output "cloudfront_domain" {
  value       = data.aws_cloudfront_distribution.lab8_frontend.domain_name
  description = "Dominio de la distribución CloudFront del Lab 8"
}
