data "aws_caller_identity" "current" {}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_handler.py"
  output_path = "${path.module}/lambda_handler.zip"
}
