resource "aws_lambda_function" "ec2_start_stop" {
  function_name = var.lambda_function_name
  filename = "${path.module}/lambda_handler.zip"
  handler = "lambda_handler.lambda_handler"
  runtime = "python3.8"

  role = aws_iam_role.lambda_ec2_start_stop.arn

  environment {
    variables = {
      TAG_FILTERS = jsonencode(var.instance_tags)
    }
  }
}


resource "aws_cloudwatch_event_rule" "start_ec2_instances" {
  name        = "${var.lambda_function_name}__start"
  description = "Scheduled start event for EC2 instances"
  schedule_expression = var.schedule_start
}

resource "aws_cloudwatch_event_rule" "stop_ec2_instances" {
  name        = "${var.lambda_function_name}__stop"
  description = "Scheduled stop event for EC2 instances"
  schedule_expression = var.schedule_stop
}

resource "aws_cloudwatch_event_target" "start_ec2_instances" {
  rule      = aws_cloudwatch_event_rule.start_ec2_instances.name
  target_id = "StartEC2Instances"
  arn       = aws_lambda_function.ec2_start_stop.arn
}

resource "aws_cloudwatch_event_target" "stop_ec2_instances" {
  rule      = aws_cloudwatch_event_rule.stop_ec2_instances.name
  target_id = "StopEC2Instances"
  arn       = aws_lambda_function.ec2_start_stop.arn
}

resource "aws_lambda_permission" "start_ec2_instances" {
  statement_id  = "AllowExecutionFromCloudWatchStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_start_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_ec2_instances.arn
}

resource "aws_lambda_permission" "stop_ec2_instances" {
  statement_id  = "AllowExecutionFromCloudWatchStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_start_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_ec2_instances.arn
}


resource "aws_cloudwatch_log_group" "ec2_start_stop_lambda_log_group" {
  name = "/aws/lambda/${var.lambda_function_name}"
}
