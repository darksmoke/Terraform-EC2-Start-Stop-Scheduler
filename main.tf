provider "aws" {
  region = var.region
}

locals {
  instance_tags  = var.instance_tags
  schedule_start = var.schedule_start
  schedule_stop  = var.schedule_stop
}


resource "aws_lambda_layer_version" "ec2_start_stop_layer" {
  filename   = data.null_data_source.lambda_zip.outputs["url"]
  layer_name = "ec2_start_stop_layer"

  source_code_hash = filebase64sha256(data.null_data_source.lambda_zip.outputs["url"])
}

resource "aws_lambda_function" "ec2_start_stop" {
  function_name = "ec2_start_stop"
  role          = aws_iam_role.lambda_ec2_start_stop.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.8"
  timeout       = 10

  environment {
    variables = {
      INSTANCE_TAGS  = jsonencode(local.instance_tags)
      SCHEDULE_START = local.schedule_start
      SCHEDULE_STOP  = local.schedule_stop
    }
  }

  layers = [
    aws_lambda_layer_version.ec2_start_stop_layer.arn
  ]
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

