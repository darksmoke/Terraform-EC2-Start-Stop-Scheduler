data "null_data_source" "lambda_code" {
  inputs = {
    url = "https://raw.githubusercontent.com/darksmoke/Terraform-EC2-Start-Stop-Scheduler/main/lambda/lambda_handler.py"
  }
}
