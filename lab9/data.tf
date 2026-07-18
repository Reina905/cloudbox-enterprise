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

# API Gateway del Lab 7: busca por nombre del REST API
data "aws_api_gateway_rest_api" "lab7_api" {
  name = "FilesAPI"
}

# Distribución de CloudFront del Lab 8 (frontend React)
data "aws_cloudfront_distribution" "lab8_frontend" {
  id = "E1ACJ7XCVDINLQ"
}
