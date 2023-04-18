provider "aws" {
  region = var.region
}

locals {
  instance_tags  = var.instance_tags
  schedule_start = var.schedule_start
  schedule_stop  = var.schedule_stop
}



resource "aws_lambda_function" "ec2_start_stop" {
  function_name    = "ec2_start_stop"
  role             = aws_iam_role.lambda_ec2_start_stop.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
  timeout          = 10

  environment {
    variables = {
      INSTANCE_TAGS  = jsonencode(local.instance_tags)
      SCHEDULE_START = local.schedule_start
      SCHEDULE_STOP  = local.schedule_stop
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
      last_modified
    ]
  }
}

resource "null_resource" "upload_lambda_code" {
  triggers = {
    code_sha256 = filebase64sha256(data.null_data_source.lambda_code.outputs["url"])
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo '${data.null_data_source.lambda_code.outputs["url"]}' > index.py
      aws lambda update-function-code --function-name ${aws_lambda_function.ec2_start_stop.function_name} --zip-file fileb://index.py --publish --region ${var.region}
      rm index.py
    EOT
  }
}




resource "aws_cloudwatch_event_rule" "start_instances" {
  name                = "start_instances"
  schedule_expression = var.schedule_start
}

resource "aws_cloudwatch_event_rule" "stop_instances" {
  name                = "stop_instances"
  schedule_expression = var.schedule_stop
}

resource "aws_cloudwatch_event_target" "start_instances_target" {
  rule      = aws_cloudwatch_event_rule.start_instances.name
  target_id = "start_instances_lambda"
  arn       = aws_lambda_function.ec2_start_stop.arn
}

resource "aws_cloudwatch_event_target" "stop_instances_target" {
  rule      = aws_cloudwatch_event_rule.stop_instances.name
  target_id = "stop_instances_lambda"
  arn       = aws_lambda_function.ec2_start_stop.arn
}

resource "aws_lambda_permission" "start_instances_permission" {
  statement_id  = "AllowExecutionFromCloudWatchStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_start_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_instances.arn
}

resource "aws_lambda_permission" "stop_instances_permission" {
  statement_id  = "AllowExecutionFromCloudWatchStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_start_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_instances.arn
}

