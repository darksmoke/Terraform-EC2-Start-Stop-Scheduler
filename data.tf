data "null_data_source" "lambda_zip" {
  inputs = {
    url = "https://github.com/darksmoke/Terraform-EC2-Start-Stop-Scheduler/raw/main/lambda.zip"
  }
}
