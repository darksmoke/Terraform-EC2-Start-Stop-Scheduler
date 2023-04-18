variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "instance_tags" {
  description = "Tags for the EC2 instances to be started and stopped"
  type        = map(string)
  default     = {}
}

variable "schedule_start" {
  description = "Cron expression for the start of the EC2 instances"
  default     = "cron(0 0 * * ? *)"
}

variable "schedule_stop" {
  description = "Cron expression for the stopping of the EC2 instances"
  default     = "cron(0 12 * * ? *)"
}
