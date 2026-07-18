variable "lambda_role_arn" {
  type = string
}

variable "queue_url" {
  type        = string
  description = "URL de la cola SQS documents-queue (Lab 9)"
  default     = ""
}
