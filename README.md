# Terraform EC2 Start/Stop Scheduler Module

This Terraform module creates an AWS Lambda function and associated resources to start and stop EC2 instances based on a specified schedule.

## Features

- Automatically starts and stops EC2 instances based on a cron schedule.
- Uses AWS EventBridge to trigger the Lambda function.
- Supports filtering EC2 instances using instance tags.

## Usage

1. Add the module to your Terraform configuration:

```hcl
module "ec2_start_stop_scheduler" {
  source         = "git::github.com/darksmoke/Terraform-EC2-Start-Stop-Scheduler?ref=main"
  lambda_name    = "ec2_start_stop_scheduler"
  instance_tags  = { "Environment" = "dev" }
  schedule_start = "cron(0 6 * * ? *)"
  schedule_stop  = "cron(0 18 * * ? *)"
}
```
2. Times for schedule_start and schedule_stop are in UTC.

3. Customize the following variables:

- `lambda_name`: A unique name for the Lambda function.
- `instance_tags`: A map of tags used to filter the EC2 instances that will be started and stopped by the Lambda function.
- `schedule_start`: A cron expression representing the schedule for starting EC2 instances.
- `schedule_stop`: A cron expression representing the schedule for stopping EC2 instances.

4. Run `terraform init` and `terraform apply` to create the resources.

## Requirements

- Terraform v0.12 or later
- AWS provider v3.0 or later

## Inputs

| Name            | Description                                                 | Type   | Default | Required |
|-----------------|-------------------------------------------------------------|--------|---------|----------|
| lambda_name     | A unique name for the Lambda function.                      | string | n/a     | yes      |
| instance_tags   | A map of tags used to filter the EC2 instances.             | map    | n/a     | yes      |
| schedule_start  | A cron expression for the EC2 instances start schedule.     | string | n/a     | yes      |
| schedule_stop   | A cron expression for the EC2 instances stop schedule.      | string | n/a     | yes      |

## Outputs

| Name                         | Description                                               |
|------------------------------|-----------------------------------------------------------|
| ec2_start_stop_scheduler_account_id | The AWS account ID where the ec2_start_stop_scheduler Lambda function is created |
| lambda_function_arn | The ARN of the created Lambda function |
