# ─── createFile ───────────────────────────────────────────────
data "archive_file" "create_file_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/createFile"
  output_path = "${path.root}/lambda/createFile.zip"
}

resource "aws_lambda_function" "create_file" {
  function_name    = "createFile"
  filename         = data.archive_file.create_file_zip.output_path
  source_code_hash = data.archive_file.create_file_zip.output_base64sha256
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  role             = var.lambda_role_arn
  timeout          = 10

  environment {
    variables = {
      QUEUE_URL = var.queue_url
    }
  }
}

# ─── getFiles ─────────────────────────────────────────────────
data "archive_file" "get_files_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/getFiles"
  output_path = "${path.root}/lambda/getFiles.zip"
}

resource "aws_lambda_function" "get_files" {
  function_name    = "getFiles"
  filename         = data.archive_file.get_files_zip.output_path
  source_code_hash = data.archive_file.get_files_zip.output_base64sha256
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  role             = var.lambda_role_arn
  timeout          = 10
}

# ─── getFileById ──────────────────────────────────────────────
data "archive_file" "get_file_by_id_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/getFileById"
  output_path = "${path.root}/lambda/getFileById.zip"
}

resource "aws_lambda_function" "get_file_by_id" {
  function_name    = "getFileById"
  filename         = data.archive_file.get_file_by_id_zip.output_path
  source_code_hash = data.archive_file.get_file_by_id_zip.output_base64sha256
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  role             = var.lambda_role_arn
  timeout          = 10
}

# ─── updateFile ───────────────────────────────────────────────
data "archive_file" "update_file_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/updateFile"
  output_path = "${path.root}/lambda/updateFile.zip"
}

resource "aws_lambda_function" "update_file" {
  function_name    = "updateFile"
  filename         = data.archive_file.update_file_zip.output_path
  source_code_hash = data.archive_file.update_file_zip.output_base64sha256
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  role             = var.lambda_role_arn
  timeout          = 10
}

# ─── deleteFile ───────────────────────────────────────────────
data "archive_file" "delete_file_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/deleteFile"
  output_path = "${path.root}/lambda/deleteFile.zip"
}

resource "aws_lambda_function" "delete_file" {
  function_name    = "deleteFile"
  filename         = data.archive_file.delete_file_zip.output_path
  source_code_hash = data.archive_file.delete_file_zip.output_base64sha256
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  role             = var.lambda_role_arn
  timeout          = 10
}
