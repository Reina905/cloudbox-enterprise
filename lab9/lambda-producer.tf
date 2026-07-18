# Reemplaza a la función createFile del Lab 7.
# En lugar de escribir en DynamoDB, envía mensajes a SQS.

resource "aws_lambda_function" "producer" {
  filename         = "${path.root}/backend/producer.zip"
  source_code_hash = filebase64sha256("${path.root}/backend/producer.zip")
  function_name    = "documents-producer"
  role             = data.aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 10

  # Variable de entorno: URL de la cola SQS
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.documents_queue.id
    }
  }
}
