resource "aws_lambda_function" "consumer" {
  filename         = "${path.root}/backend/consumer.zip"
  source_code_hash = filebase64sha256("${path.root}/backend/consumer.zip")
  function_name    = "documents-consumer"
  role             = data.aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 30

  # Variable de entorno: nombre de la tabla DynamoDB
  environment {
    variables = {
      TABLE_NAME = data.aws_dynamodb_table.documents.name
    }
  }
}

#  Event Source Mapping: conecta SQS con la Lambda Consumidora 
# AWS invocará automáticamente la Lambda cuando haya mensajes en la cola.
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.documents_queue.arn
  function_name    = aws_lambda_function.consumer.arn
  batch_size       = 1
}
