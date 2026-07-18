#  Permiso para que la Lambda Productora envíe mensajes a SQS 
resource "aws_iam_role_policy" "producer_sqs_policy" {
  name = "producer-sqs-policy"
  role = data.aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.documents_queue.arn
      }
    ]
  })
}

#  Permiso para que la Lambda Consumidora escriba en DynamoDB 
resource "aws_iam_role_policy" "consumer_dynamodb_policy" {
  name = "consumer-dynamodb-policy"
  role = data.aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
        ]
        Resource = data.aws_dynamodb_table.documents.arn
      }
    ]
  })
}

#  Permiso para que la Lambda Consumidora lea mensajes de SQS 
resource "aws_iam_role_policy" "consumer_sqs_policy" {
  name = "consumer-sqs-policy"
  role = data.aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.documents_queue.arn
      }
    ]
  })
}
