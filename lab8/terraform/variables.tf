variable "project_name" {
  type        = string
  description = "Nombre del proyecto"
}

variable "aws_region" {
  type        = string
  description = "Region de AWS"
}

variable "api_url" {
  type        = string
  description = "URL del API Gateway obtenida del Lab 7"
}

variable "user_pool_id" {
  type        = string
  description = "Cognito User Pool ID obtenido del Lab 7"
}

variable "client_id" {
  type        = string
  description = "Cognito App Client ID obtenido del Lab 7"
}
