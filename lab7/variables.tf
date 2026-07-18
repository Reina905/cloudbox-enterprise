variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "queue_url" {
  type        = string
  description = "URL de la cola SQS del Lab 9 (documents-queue)"
  default     = ""
}
