# DATA SOURCES
# Referencian la infraestructura existente del Laboratorio 7

# IAM Role existente del Lab 7 (cloudbox-lambda-role)
data "aws_iam_role" "lambda_role" {
  name = "cloudbox-lambda-role"
}

# Tabla DynamoDB existente del Lab 7
data "aws_dynamodb_table" "documents" {
  name = "Files"
}

# Lambda Productora existente del Lab 7 (createFile)
data "aws_lambda_function" "producer" {
  function_name = "createFile"
}
