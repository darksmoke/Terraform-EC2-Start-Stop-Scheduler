output "lambda_function_arn" {
  description = "The ARN of the created Lambda function"
  value       = aws_lambda_function.ec2_start_stop.arn
}

output "aws_account_id" {
  description = "The AWS account ID where the Lambda function is created"
  value       = data.aws_caller_identity.current.account_id
}