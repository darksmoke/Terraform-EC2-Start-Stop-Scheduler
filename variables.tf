variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "ec2_start_stop_scheduler"
}


variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "instance_tags" {
  description = "A map of tags to filter instances for starting and stopping"
  type        = map(string)
}

variable "schedule_start" {
  description = "The cron expression for starting instances"
  type        = string
}

variable "schedule_stop" {
  description = "The cron expression for stopping instances"
  type        = string
}
