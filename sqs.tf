# AMAZON SQS

#  Dead Letter Queue 
resource "aws_sqs_queue" "documents_dlq" {
  name = "documents-dlq"
}


resource "aws_sqs_queue" "documents_queue" {
  name = "documents-queue"

  # Evita que varios consumidores procesen simultáneamente el mismo mensaje.
  visibility_timeout_seconds = 30

  # Política de reintento: tras 3 fallos, el mensaje pasa a la DLQ.
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.documents_dlq.arn
    maxReceiveCount     = 3
  })
}
