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
