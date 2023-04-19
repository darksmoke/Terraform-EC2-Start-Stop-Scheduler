resource "aws_iam_role" "lambda_ec2_start_stop" {
  name = "lambda_ec2_start_stop_${var.lambda_function_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_ec2_start_stop" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_ec2_start_stop.name
}

resource "aws_iam_policy" "ec2_start_stop" {
  name        = "ec2_start_stop_${var.lambda_function_name}"
  path        = "/"
  description = "EC2 Start/Stop policy for Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_start_stop_policy" {
  policy_arn = aws_iam_policy.ec2_start_stop.arn
  role       = aws_iam_role.lambda_ec2_start_stop.name
}
