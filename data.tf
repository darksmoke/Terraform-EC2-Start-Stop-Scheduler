data "http" "lambda_zip" {
  url = "https://github.com/darksmoke/Terraform-EC2-Start-Stop-Scheduler/raw/main/lambda.zip"
}

data "archive_file" "lambda_zip" {
  type          = "zip"
  source_content = data.http.lambda_zip.body
  output_path   = "lambda.zip"
}
